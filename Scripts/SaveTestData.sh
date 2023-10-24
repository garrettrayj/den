#!/bin/sh

#  SaveTestData.sh
#  Den
#
#  Created by Garrett Johnson on 7/29/23.
#  Copyright © 2023 Garrett Johnson

rm -rf /tmp/TestData/en.xcappdata/AppData
mkdir -p /tmp/TestData/en.xcappdata/AppData

cp -r $(xcrun simctl get_app_container "iPad Air (5th generation)" net.devsci.den data)/ /tmp/TestData/en.xcappdata/AppData/

rm -rf ./TestData/en.xcappdata/AppData
mkdir -p ./TestData/en.xcappdata/AppData/Library/Application\ Support/Den

cp -a /tmp/TestData/en.xcappdata/AppData/Library/Application\ Support/Den/ ./TestData/en.xcappdata/AppData/Library/Application\ Support/Den/

cp -a /tmp/TestData/en.xcappdata/AppData/Library/Preferences/ ./TestData/en.xcappdata/AppData/Library/Preferences/

cp -a /tmp/TestData/en.xcappdata/AppData/Library/Saved\ Application\ State/ ./TestData/en.xcappdata/AppData/Library/Saved\ Application\ State/
