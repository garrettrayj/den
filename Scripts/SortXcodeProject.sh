#!/bin/sh

#  SortXcodeProject.sh
#  Den
#
#  Created by Garrett Johnson on 7/29/23.
#  Copyright © 2023 Garrett Johnson
#
#  SPDX-License-Identifier: MIT

SCRIPTS_DIR=$(dirname -- "$0")
PROJECT_DIR=$(dirname -- "$SCRIPTS_DIR")
PROJECT_FILE="$PROJECT_DIR/Den.xcodeproj/project.pbxproj"

perl "${SCRIPTS_DIR}/SortXcodeProject.pl" "${PROJECT_FILE}"
