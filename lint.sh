#!/bin/sh

#  lint.sh
#  Den
#
#  Created by Garrett Johnson on 1/2/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
#

if which swiftlint >/dev/null; then
swiftlint --fix && swiftlint
else echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
