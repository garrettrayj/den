#!/bin/sh

#  Lint.sh
#  Den
#
#  Created by Garrett Johnson on 1/2/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT
#

if [ -f "/opt/homebrew/bin/swiftlint" ]; then
/opt/homebrew/bin/swiftlint
else
echo "warning: SwiftLint not installed. Run `brew install swiftlint`"
fi
