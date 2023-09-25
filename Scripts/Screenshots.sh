#!/bin/zsh

#  Screenshots.sh
#  Den
#
#  Created by Garrett Johnson on 7/18/21.
#  Copyright © 2021 Garrett Johnson
#
#  SPDX-License-Identifier: MIT

set -e

# The Xcode project to create screenshots for
projectName="./Den.xcodeproj"

# The scheme and bundle to run
schemeName="Den"

# All the simulators we want to screenshot
# Copy/Paste new names from Xcode's "Devices and Simulators" window or from `xcrun simctl list`.
simulators=(
    "iPhone 12 Pro Max"
    "iPhone 14 Pro Max"
    "iPad Pro (12.9-inch) (5th generation)"
    "iPad Pro (12.9-inch) (2nd generation)"
)

# Save final screenshots into this folder (it will be created)
targetFolder="$HOME/Desktop/DenScreenshots"

sdk="iphoneos17.0"

function capture_mac {
    # Capture macOS screenshots
    rm -rf /tmp/DenDerivedData/Logs/Test
    
    rm -rf "$HOME/Library/Containers/net.devsci.den/Data/*"

    cp -a "./TestData/en.xcappdata/AppData/." "$HOME/Library/Containers/net.devsci.den/Data"

    xcodebuild \
        -project $projectName \
        -scheme $schemeName \
        -testPlan Marketing \
        -derivedDataPath '/tmp/DenDerivedData/' \
        test
        
    echo "🖼  Collecting macOS results..."
    destination="$targetFolder/macOS"
    rm -rf "$destination"
    mkdir -p "$destination"
    find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$destination" \;
    
    # Remove UUID from screenshot filenames
    for file ($destination/*.png(ND.)) {
        new_name=${file/_1_*\.png/\.png}
        mv -f "$file" "$new_name"
    }
    
    echo "✅  Mac Screenshots Done"
}

function capture_ios {
    # Capture iOS screenshots
    for simulator in "${simulators[@]}"
    do
        simulator_name="$simulator Screenshots"
        
        xcrun simctl create "$simulator_name" "$simulator"
        xcrun simctl boot "$simulator_name"
        
        xcodebuild \
            -project $projectName \
            -scheme $schemeName \
            -derivedDataPath '/tmp/DenDerivedData/' \
            -destination "platform=iOS Simulator,name=$simulator_name" \
            -sdk $sdk \
            build-for-testing
            
        xcrun simctl install "$simulator_name" /tmp/DenDerivedData/Build/Products/Debug-iphonesimulator/Den.app
        
        __IS_NOT_MACOS="YES" PROJECT_DIR="$(pwd)/" ./Scripts/LoadTestData.sh

        rm -rf /tmp/DenDerivedData/Logs/Test
        echo "📲  Building and running for $appearance $simulator in $language"

        xcodebuild \
            -project $projectName \
            -scheme $schemeName \
            -testPlan Marketing \
            -derivedDataPath '/tmp/DenDerivedData/' \
            -destination "platform=iOS Simulator,name=$simulator_name" \
            -sdk $sdk \
            test-without-building
            
        echo "🖼  Collecting Results..."
        destination="$targetFolder/$simulator"
        rm -rf "$destination"
        mkdir -p "$destination"
        find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$destination" \;
        
        # Remove UUID from screenshot filenames
        for file ($destination/*.png(ND.)) {
            new_name=${file/_1_*\.png/\.png}
            mv -f "$file" "$new_name"
        }
        
        # Expand filenames to directory paths
        for file ($destination/*.png(ND.)) {
            new_name="${file//+//}"
            mkdir -p "$(dirname "$new_name")"
            mv "${file}" "${new_name}"
        }
        
        xcrun simctl shutdown "$simulator_name"
        xcrun simctl delete "$simulator_name"

        echo "✅  $simulator Screenshots Done"
    done
}

start_time=$SECONDS

capture_ios

elapsed=$(( SECONDS - start_time ))

eval "echo 🎉  Capture completed in $(bc <<<"scale=2; $elapsed / 60") minutes"
