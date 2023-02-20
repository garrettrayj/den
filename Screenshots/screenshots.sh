#!/bin/zsh

#  screenshots.sh
#  Den
#
#  Created by Garrett Johnson on 7/18/21.
#  Copyright © 2021 Garrett Johnson
set -e

# The Xcode project to create screenshots for
projectName="./Den.xcodeproj"

# The scheme and bundle to run
schemeName="Den"
testBundle="Screenshots"

# All the simulators we want to screenshot
# Copy/Paste new names from Xcode's "Devices and Simulators" window or from `xcrun simctl list`.
simulators=(
    "iPhone 12 Pro Max"
    "iPhone 8 Plus"
    "iPad Pro (12.9-inch) (5th generation)"
    "iPad Pro (12.9-inch) (2nd generation)"
)

# All the languages we want to screenshot (ISO 3166-1 codes)
languages=(
    "en"
)

# All the appearances we want to screenshot (options are "light" and "dark")
appearances=(
    "light"
    #"dark"
)

# Save final screenshots into this folder (it will be created)
targetFolder="$PWD/Screenshots/Images"

function capture_mac {
    # Capture macOS screenshots
    for language in "${languages[@]}"
    do
        for appearance in "${appearances[@]}"
        do
            rm -rf /tmp/DenDerivedData/Logs/Test

            xcodebuild \
                -testLanguage $language \
                -scheme $schemeName \
                -project $projectName \
                -derivedDataPath '/tmp/DenDerivedData/' \
                -only-testing:$testBundle \
                build test

            echo "🖼  Collecting macOS results..."
            destination="$targetFolder/macOS/$language/$appearance"
            mkdir -p "$destination"
            find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$destination" \;
            
            # Remove UUID from screenshot filenames
            for file ($destination/*.png(ND.)) {
                new_name=${file/_1_*\.png/\.png}
                mv -f "$file" "$new_name"
            }
        done
    done
    echo "✅  Mac Screenshots Done"
}

function capture_ios {
    # Capture iOS screenshots
    for simulator in "${simulators[@]}"
    do
        simulator_name="$simulator Screenshots"
        
        xcrun simctl create "$simulator_name" "$simulator"
        xcrun simctl boot "$simulator_name"

        for language in "${languages[@]}"
        do
            for appearance in "${appearances[@]}"
            do
                rm -rf /tmp/DenDerivedData/Logs/Test
                echo "📲  Building and running for $appearance $simulator in $language"
                
                xcrun simctl ui "$simulator_name" appearance $appearance

                # Build and Test
                xcodebuild \
                    -testLanguage $language \
                    -scheme $schemeName \
                    -project $projectName \
                    -derivedDataPath '/tmp/DenDerivedData/' \
                    -destination "platform=iOS Simulator,name=$simulator_name" \
                    -only-testing:$testBundle \
                    build test
                    
                echo "🖼  Collecting Results..."
                destination="$targetFolder/$simulator/$language/$appearance"
                mkdir -p "$destination"
                find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$destination" \;
                
                # Remove UUID from screenshot filenames
                for file ($destination/*.png(ND.)) {
                    new_name=${file/_1_*\.png/\.png}
                    mv -f "$file" "$new_name"
                }
            done
        done
        
        xcrun simctl shutdown "$simulator_name"
        xcrun simctl delete "$simulator_name"

        echo "✅  iOS Screenshots Done"
    done
}

start_time=$SECONDS

#capture_mac
capture_ios

elapsed=$(( SECONDS - start_time ))

eval "echo 🎉  Capture completed in $(bc <<<"scale=2; $elapsed / 60") minutes"
