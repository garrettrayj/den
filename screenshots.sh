#!/bin/zsh

#  screenshots.sh
#  Den
#
#  Created by Garrett Johnson on 7/18/21.
#  Copyright © 2021 Garrett Johnson. All rights reserved.
set -e

rm -rf /tmp/DenDerivedData/

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
            
            # Attempt to shutdown simulator in case it's already booted
            xcrun simctl shutdown "$simulator" || true

            # Boot up then simulator and set the appearance
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
            destination="$targetFolder/$simulator/$language/$appearance"
            mkdir -p "$destination"
            find /tmp/DenDerivedData/Logs/Test -maxdepth 1 -type d -exec xcparse screenshots {} "$destination" \;
            
            # Remove UUID from screenshot filenames
            for file ($destination/*.png(ND.)) {
                new_name=${file/_1_*\.png/\.png}
                mv -f "$file" "$new_name"
            }
            
            xcrun simctl shutdown "$simulator"
        done
    done

    echo "✅  iOS Screenshots Done"
done


