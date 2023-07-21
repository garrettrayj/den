#!/bin/sh

#  Lint.sh
#  Den
#
#  Created by Garrett Johnson on 1/2/23.
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

if exists swiftlint; then
    swiftlint --fix && swiftlint
else
    echo "warning: SwiftLint not installed. Run `brew install swiftlint`"
fi
