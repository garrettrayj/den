#!/bin/zsh
#
#  Screenshots.sh
#  Den
#
#  Created by Garrett Johnson on 7/18/21.
#  Copyright © 2021 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
#

set -e

projectName="./Den.xcodeproj"
schemeName="Den"
testPlan="Default"
derivedDataPath="/tmp/DenDerivedData/"
targetFolder="$HOME/Desktop/DenScreenshots"

# List of iOS simulators to capture. Run `xcrun simctl list` to view options.
simulators=(
    "iPhone 15"
    "iPhone 15 Plus"
    "iPad Pro (11-inch) (4th generation)"
    "iPad Pro (12.9-inch) (6th generation)"
    "iPad Pro (12.9-inch) (2nd generation)"
)

function capture_ios {
    for simulator in "${simulators[@]}"
    do
        # Boot simulator
        simulator_name="$simulator Screenshots"
        xcrun simctl create "$simulator_name" "$simulator"
        xcrun simctl boot "$simulator_name"
        
        # Build project for testing
        xcodebuild \
            -project $projectName \
            -scheme $schemeName \
            -derivedDataPath $derivedDataPath \
            -destination "platform=iOS Simulator,name=$simulator_name" \
            build-for-testing
        
        # Install application on simulator
        xcrun simctl install "$simulator_name" "$derivedDataPath/Build/Products/Debug-iphonesimulator/Den.app"
        
        # Load test data (must be run after installation)
        __IS_NOT_MACOS="YES" PROJECT_DIR="." ./Scripts/LoadTestData.sh

        # Remove previous test results
        rm -rf "$derivedDataPath/Logs/Test"
        
        # Run UI tests to capture screenshots
        echo "📲  Building and running for $appearance $simulator in $language"
        xcodebuild \
            -project $projectName \
            -scheme $schemeName \
            -testPlan $testPlan \
            -derivedDataPath $derivedDataPath \
            -destination "platform=iOS Simulator,name=$simulator_name" \
            test-without-building
        
        # Run xcparse to extract screenshots from test results
        echo "🖼  Collecting Results..."
        destination="$targetFolder/$simulator"
        rm -rf "$destination"
        mkdir -p "$destination"
        find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$destination" \;
        
        # Remove UUID from screenshot filenames
        for file ($destination/*.png(ND.)) {
            new_name=${file/_0_*\.png/\.png}
            mv -f "$file" "$new_name"
        }
        
        # Expand filenames to directory paths
        for file ($destination/*.png(ND.)) {
            new_name="${file//+//}"
            mkdir -p "$(dirname "$new_name")"
            mv "${file}" "${new_name}"
        }
        
        # Cleanup
        xcrun simctl shutdown "$simulator_name"
        xcrun simctl delete "$simulator_name"

        echo "✅  $simulator Screenshots Done"
    done
}

function capture_mac {
    # Load test data
    __IS_NOT_MACOS="NO" PROJECT_DIR="." ./Scripts/LoadTestData.sh

    # Remove previous test results
    rm -rf /tmp/DenDerivedData/Logs/Test

    # Run UI tests to capture screenshots
    xcodebuild \
        -project $projectName \
        -scheme $schemeName \
        -testPlan $testPlan \
        -derivedDataPath $derivedDataPath \
        test
    
    # Run xcparse to extract screenshots from test results
    echo "🖼  Collecting macOS results..."
    destination="$targetFolder/macOS"
    rm -rf "$destination"
    mkdir -p "$destination"
    find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$destination" \;
    
    # Remove UUID from screenshot filenames
    for file ($destination/*.png(ND.)) {
        new_name=${file/_0_*\.png/\.png}
        mv -f "$file" "$new_name"
    }
    
    # Expand filenames to directory paths
    for file ($destination/*.png(ND.)) {
        new_name="${file//+//}"
        mkdir -p "$(dirname "$new_name")"
        mv "${file}" "${new_name}"
    }
    
    echo "✅  Mac Screenshots Done"
}

start_time=$SECONDS

if [ "$1" = "mac" ]; then
    capture_mac
else
    capture_ios
fi

elapsed=$(( SECONDS - start_time ))

eval "echo 🎉  Capture completed in $(bc <<<"scale=2; $elapsed / 60") minutes"
