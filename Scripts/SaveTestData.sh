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

appSupportDirectory="$groupDirectory/Library/Application Support"

mkdir -p "./TestData/Library/Application Support/"
cp "$appSupportDirectory/Den.sqlite" "./TestData/Library/Application Support/"
cp "$appSupportDirectory/Den.sqlite-wal" "./TestData/Library/Application Support/"
cp "$appSupportDirectory/Den-Local.sqlite" "./TestData/Library/Application Support/"
cp "$appSupportDirectory/Den-Local.sqlite-wal" "./TestData/Library/Application Support/"

mkdir -p "./TestData/Library/Preferences/"

cp "$groupDirectory/Library/Preferences/group.net.devsci.den.plist" "./TestData/Library/Preferences/"
