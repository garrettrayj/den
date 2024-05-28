#!/bin/sh

#  SaveTestData.sh
#  Den
#
#  Created by Garrett Johnson on 7/29/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
set -e

rm -rf ./TestData/Library
mkdir -p ./TestData/Library

groupDirectory="$HOME/Library/Group Containers/group.net.devsci.den"
groupAppSupportDirectory="$groupDirectory/Library/Application Support"

mkdir -p "./TestData/Group/Library/Application Support/"
cp "$groupAppSupportDirectory/Den.sqlite" "./TestData/Group/Library/Application Support/"
cp "$groupAppSupportDirectory/Den.sqlite-wal" "./TestData/Group/Library/Application Support/"
cp "$groupAppSupportDirectory/Den-Local.sqlite" "./TestData/Group/Library/Application Support/"
cp "$groupAppSupportDirectory/Den-Local.sqlite-wal" "./TestData/Group/Library/Application Support/"

appPreferences="$HOME/Library/Containers/net.devsci.den/Data/Library/Preferences/net.devsci.den.plist"

mkdir -p "./TestData/App/Library/Preferences/"
cp "$appPreferences" "./TestData/App/Library/Preferences/net.devsci.den.plist"
