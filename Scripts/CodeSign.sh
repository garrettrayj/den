#!/bin/sh

#  CodeSign.sh
#  Den
#
#  Created by Garrett Johnson on 8/6/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
#
#  Sign Sparkle components
#

# Create logs folder
logsFolder="${PROJECT_DIR}/Scripts/Logs"
mkdir -p $logsFolder

# Create log file
scriptNameWithExtension=$(basename "$0")
scriptNameClean=${scriptNameWithExtension%.*}
exec > "$logsFolder/$scriptNameClean.log" 2>&1
set -o pipefail
set -e

codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime "$BUILT_PRODUCTS_DIR/Sparkle.framework/Versions/B/XPCServices/Installer.xpc"

codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime "$BUILT_PRODUCTS_DIR/Sparkle.framework/Versions/B/Autoupdate"
codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime "$BUILT_PRODUCTS_DIR/Sparkle.framework/Versions/B/Updater.app"

codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime "$BUILT_PRODUCTS_DIR/Sparkle.framework"
