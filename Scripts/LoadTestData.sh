#!/bin/sh

#  LoadTestData.sh
#  Den
#
#  Created by Garrett Johnson on 7/15/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
#
#  Install app data from .xcappdata package. Invoked in Scheme > Test > Pre-actions.
#

# Create logs folder
logsFolder=${PROJECT_DIR}/Scripts/Logs
mkdir -p $logsFolder

# Create log file
scriptNameWithExtension=$(basename "$0")
scriptNameClean=${scriptNameWithExtension%.*}
exec > "$logsFolder/$scriptNameClean.log" 2>&1
set -o pipefail
set -e

runDate=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$__IS_NOT_MACOS" == "NO" ]
then
    echo "$runDate Load MacOS Test Data"
    rm -rf $HOME/Library/Containers/net.devsci.den/Data/*
    copyCommand="cp -a $PROJECT_DIR/TestData/en.xcappdata/AppData/. $HOME/Library/Containers/net.devsci.den/Data"
    echo $copyCommand
    exec $copyCommand
else
    echo "$runDate Load Simulator Test Data"
    echo $PROJECT_DIR
    uuidRegex="([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})"
    device=$(xcrun simctl list | grep Booted | grep -E -o -i $uuidRegex | head -1)
    appContainer=$(xcrun simctl get_app_container $device net.devsci.den data)
    
    echo "Device:    $device"
    echo "Container: $appContainer"
    
    copyCommand="cp -a $PROJECT_DIR/TestData/en.xcappdata/AppData/. $appContainer/"
    echo $copyCommand
    exec $copyCommand
fi
