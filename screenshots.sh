#!/bin/sh

#  screenshots.sh
#  Den
#
#  Created by Garrett Johnson on 7/18/21.
#  Copyright © 2021 Garrett Johnson. All rights reserved.
set -e

# The Xcode project to create screenshots for
projectName="./Den.xcodeproj"

# The scheme and bundle to run
schemeName="Den"
testBundle="DenScreenshots"

# All the simulators we want to screenshot
# Copy/Paste new names from Xcode's "Devices and Simulators" window or from `xcrun simctl list`.
simulators=(
    "iPhone 12 Pro Max"
    "iPhone 12 Pro"
    "iPhone 8 Plus"
    "iPhone 8"
    "iPad Pro (12.9-inch) (5th generation)"
    "iPad Pro (12.9-inch) (2nd generation)"
    "iPad Pro (11-inch) (3rd generation)"
    "iPad Pro (10.5-inch)"
    "iPad Pro (9.7-inch)"
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
targetFolder="$PWD/Documents/Screenshots"
rm -rf $targetFolder/*

rm -rf /tmp/DenDerivedData

for language in "${languages[@]}"
do
    for appearance in "${appearances[@]}"
    do
        rm -rf /tmp/DenDerivedData/Logs/Test
    
        # Capture macOS screenshots
        xcodebuild \
            -testLanguage $language \
            -scheme $schemeName \
            -project $projectName \
            -derivedDataPath '/tmp/DenDerivedData/' \
            -destination "platform=macOS,arch=x86_64,variant=Mac Catalyst" \
            -only-testing:$testBundle \
            build test
            
        echo "🖼  Collecting macOS results..."
        mkdir -p "$targetFolder/macOS/$language/$appearance"
        find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$targetFolder/$simulator/$language/$appearance" \;
    
        # Run iOS simulators for iPhone and iPad screenshots
        for simulator in "${simulators[@]}"
        do
            rm -rf /tmp/DenDerivedData/Logs/Test
            echo "📲  Building and Running for $simulator in $language with $appearance appearance"

            # Boot up the new simulator and set it to the correct appearance
            xcrun simctl boot "$simulator"
            xcrun simctl ui "$simulator" appearance $appearance

            # Build and Test
            xcodebuild \
                -testLanguage $language \
                -scheme $schemeName \
                -project $projectName \
                -derivedDataPath '/tmp/DenDerivedData/' \
                -destination "platform=iOS Simulator,name=$simulator" \
                -only-testing:$testBundle \
                build test
            echo "🖼  Collecting $simulator results..."
            mkdir -p "$targetFolder/$simulator/$language/$appearance"
            find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$targetFolder/$simulator/$language/$appearance" \;
        done
    done
done
echo "✅  Done"
