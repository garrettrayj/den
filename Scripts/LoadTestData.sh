#!/bin/sh
#
#  LoadTestData.sh
#  Den
#
#  Created by Garrett Johnson on 7/15/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
#
#  Loads fixture data for UI tests. Invoked in Den scheme's test pre-actions.
#  Use `Scripts/SaveTestData.sh` to export fixture data before running tests.
#

# Create logs folder
logsFolder="$PROJECT_DIR/Scripts/Logs"
mkdir -p "$logsFolder"

# Create log file
scriptNameWithExtension=$(basename "$0")
scriptNameClean=${scriptNameWithExtension%.*}
exec > "$logsFolder/$scriptNameClean.log" 2>&1
set -o pipefail
set -e

runDate=$(date '+%Y-%m-%d %H:%M:%S')

sourceGroupContainer="$PROJECT_DIR/TestData/GroupContainer"
sourceAppContainer="$PROJECT_DIR/TestData/AppContainer"

if [ "$__IS_NOT_MACOS" == "NO" ]
then
    echo "$runDate Load test data for macOS"
    
    # Copy group container data
    destinationGroupContainer="$HOME/Library/Group Containers/group.net.devsci.den"
    rm -rf "$destinationGroupContainer/Library/"*
    cp -a "$sourceGroupContainer/Library/." "$destinationGroupContainer/Library/"
    
    # Copy app container data
    destinationAppContainer="$HOME/Library/Containers/net.devsci.den"
    rm -rf "$destinationAppContainer/Data/Library/"*
    cp -a "$sourceAppContainer/Library/." "$destinationAppContainer/Data/Library/"
else
    echo "$runDate Load test data for iOS simulator"
    uuidRegex="([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})"
    device=$(xcrun simctl list | grep Booted | grep -E -o -i $uuidRegex | head -1)
    echo "Device: $device"

    # Copy group container data
    destinationGroupContainer=$(xcrun simctl get_app_container $device net.devsci.den groups | awk -F'\t' '{print $2}')
    echo "Group Container: $destinationGroupContainer"
    rm -rf "$destinationGroupContainer/Library/"*
    cp -a "$sourceGroupContainer/Library/." "$destinationGroupContainer/Library/"
    
    # Copy app container data
    destinationAppContainer=$(xcrun simctl get_app_container $device net.devsci.den data)
    echo "App Container: $destinationAppContainer"
    rm -rf "$destinationAppContainer/Library/"*
    cp -a "$sourceAppContainer/Library/." "$destinationAppContainer/Library/"
fi
