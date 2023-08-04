#!/bin/sh

#  UpdateSettingBundle.sh
#  Den
#
#  Created by Garrett Johnson on 7/20/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT

# Create logs folder
logsFolder="${PROJECT_DIR}/Scripts/Logs"
mkdir -p $logsFolder

# Create log file
scriptNameWithExtension=$(basename "$0")
scriptNameClean=${scriptNameWithExtension%.*}
exec > "$logsFolder/$scriptNameClean.log" 2>&1
set -o pipefail
set -e

version="$MARKETING_VERSION"
build="$CURRENT_PROJECT_VERSION"

/usr/libexec/PlistBuddy \
    -x -c "set PreferenceSpecifiers:4:DefaultValue $version ($build)" \
    "${SRCROOT}/Settings.bundle/Root.plist"
