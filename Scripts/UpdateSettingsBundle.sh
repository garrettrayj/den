#!/bin/sh

#  UpdateSettingBundle.sh
#  Den
#
#  Created by Garrett Johnson on 7/20/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT

version="$MARKETING_VERSION"
build="$CURRENT_PROJECT_VERSION"

/usr/libexec/PlistBuddy \
    -x -c "set PreferenceSpecifiers:4:DefaultValue $version ($build)" \
    "${SRCROOT}/Settings.bundle/Root.plist"
