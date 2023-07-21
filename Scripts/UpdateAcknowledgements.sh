#!/bin/sh

#  UpdateAcknowledgements.sh
#  Den
#
#  Created by Garrett Johnson on 7/20/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
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

eval $(/opt/homebrew/bin/brew shellenv)

exists()
{
    command -v "$1" >/dev/null 2>&1
}

if exists license-plist && [ $CONFIGURATION = "Debug" ]; then
    license-plist
else
    echo "warning: LicensePlist not installed. Run 'brew install licenseplist'"
fi
