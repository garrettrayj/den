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

codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime Sparkle.framework/Versions/B/XPCServices/Installer.xpc
codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime --entitlements Entitlements/Downloader.entitlements Sparkle.framework/Versions/B/XPCServices/Downloader.xpc

codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime Sparkle.framework/Versions/B/Autoupdate
codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime Sparkle.framework/Versions/B/Updater.app

codesign -f -s "$CODE_SIGN_IDENTITY" -o runtime Sparkle.framework
