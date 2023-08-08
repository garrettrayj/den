#!/bin/sh

#  CodeSign.sh
#  Den
#
#  Created by Garrett Johnson on 8/6/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
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

sparkleEntitlements="$PROJECT_DIR/Scripts/Sparkle.entitlements"
sparkleFramework="$BUILT_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH/Sparkle.framework"

if [ "$__IS_NOT_MACOS" == "NO" ]
then
    codesign -f -s "$EXPANDED_CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose --entitlements "$sparkleEntitlements" "$sparkleFramework/Versions/Current/XPCServices/Installer.xpc"
    codesign -f -s "$EXPANDED_CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose --entitlements "$sparkleEntitlements" "$sparkleFramework/Versions/Current/Autoupdate"
    codesign -f -s "$EXPANDED_CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose --entitlements "$sparkleEntitlements" "$sparkleFramework/Versions/Current/Updater.app"
    
    codesign -f -s "$EXPANDED_CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose "$sparkleFramework"
fi
