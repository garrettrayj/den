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
targetFolder="$PWD/Documents/Screenshots"
rm -rf $targetFolder/*

# Capture macOS screenshots
# for language in "${languages[@]}"
# do
#     for appearance in "${appearances[@]}"
#     do
#         rm -rf /tmp/DenDerivedData/Logs/Test
#
#         xcodebuild \
#             -testLanguage $language \
#             -scheme $schemeName \
#             -project $projectName \
#             -derivedDataPath '/tmp/DenDerivedData/' \
#             -only-testing:$testBundle \
#             build test
#
#         echo "🖼  Collecting macOS results..."
#         mkdir -p "$targetFolder/macOS/$language/$appearance"
#         find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$targetFolder/macOS/$language/$appearance" \;
#     done
# done
# echo "✅  Mac Screenshots Done"


# Capture iOS screenshots
for simulator in "${simulators[@]}"
do
    for language in "${languages[@]}"
    do
        for appearance in "${appearances[@]}"
        do
            rm -rf /tmp/DenDerivedData/Logs/Test
            echo "📲  Building and Running for $simulator in $language"

            # Boot up the new simulator and set it to
            # the correct appearance
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
            echo "🖼  Collecting Results..."
            mkdir -p "$targetFolder/$simulator/$language/$appearance"
            find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$targetFolder/$simulator/$language/$appearance" \;
            
            xcrun simctl shutdown "$simulator"
        done
    done

    echo "✅  iOS Screenshots Done"
done


