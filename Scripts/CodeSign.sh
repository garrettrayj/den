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

sparkleEntitlements="$PROJECT_DIR/Scripts/Sparkle.entitlements"
sparkleFramework="$BUILT_PRODUCTS_DIR/Den.app/Contents/Frameworks/Sparkle.framework"

if [ "$__IS_NOT_MACOS" == "NO" ]
then
    # Sign for debug
    codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose --entitlements "$sparkleEntitlements" "$BUILT_PRODUCTS_DIR/Sparkle.framework/Versions/B/XPCServices/Installer.xpc"
    codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose --entitlements "$sparkleEntitlements" "$BUILT_PRODUCTS_DIR/Sparkle.framework/Versions/B/Autoupdate"
    codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose --entitlements "$sparkleEntitlements" "$BUILT_PRODUCTS_DIR/Sparkle.framework/Versions/B/Updater.app"
    codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose "$BUILT_PRODUCTS_DIR/Sparkle.framework"

    # Sign for Xcode Cloud archive process
    codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose --entitlements "$sparkleEntitlements" "$sparkleFramework/Versions/B/XPCServices/Installer.xpc"
    codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose --entitlements "$sparkleEntitlements" "$sparkleFramework/Versions/B/Autoupdate"
    codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose --entitlements "$sparkleEntitlements" "$sparkleFramework/Versions/B/Updater.app"
    codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime --timestamp --force --verbose "$sparkleFramework"
fi
