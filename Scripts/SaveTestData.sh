#!/bin/sh

#  SaveTestData.sh
#  Den
#
#  Created by Garrett Johnson on 7/29/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
set -e

rm -f ./TestData/Den.sqlite
rm -f ./TestData/Den-Local.sqlite

groupDirectory=$(xcrun simctl get_app_container "iPad Air (5th generation)" net.devsci.den groups | awk -F'\t' '{print $2}')

cp -r $groupDirectory/Library/Application\ Support/Den.sqlite* ./TestData/
cp -r $groupDirectory/Library/Application\ Support/Den-Local.sqlite* ./TestData/
