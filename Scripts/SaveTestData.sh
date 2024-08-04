#!/bin/sh
#
#  SaveTestData.sh
#  Den
#
#  Created by Garrett Johnson on 7/29/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
#
#  Creates test fixture data from current installation databases and preferences.
#  Script should be run from project root with `Scripts/SaveTestData.sh`.
#  iCloud MUST be disabled for Den in macOS settings.
#

set -e

# Group Container

sourceGroupDirectory="$HOME/Library/Group Containers/group.net.devsci.den"
sourceGroupAppSupportDirectory="$sourceGroupDirectory/Library/Application Support"
destinationGroupAppSupportDirectory="./TestData/GroupContainer/Library/Application Support"

rm -rf "$destinationGroupAppSupportDirectory"
mkdir -p "$destinationGroupAppSupportDirectory"

cp "$sourceGroupAppSupportDirectory/Den.sqlite" "$destinationGroupAppSupportDirectory/"
cp "$sourceGroupAppSupportDirectory/Den.sqlite-wal" "$destinationGroupAppSupportDirectory/"
cp "$sourceGroupAppSupportDirectory/Den-Local.sqlite" "$destinationGroupAppSupportDirectory/"
cp "$sourceGroupAppSupportDirectory/Den-Local.sqlite-wal" "$destinationGroupAppSupportDirectory/"

# App Container

sourceAppPreferencesDirectory="$HOME/Library/Containers/net.devsci.den/Data/Library/Preferences"
sourceAppPreferences="$sourceAppPreferencesDirectory/net.devsci.den.plist"
destinationAppPreferencesDirectory="./TestData/AppContainer/Library/Preferences"

rm -rf "$destinationAppPreferencesDirectory"
mkdir -p "$destinationAppPreferencesDirectory"

cp $sourceAppPreferences "$destinationAppPreferencesDirectory/"
