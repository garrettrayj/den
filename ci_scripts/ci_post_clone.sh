#
#  ci_post_clone.swift
#  Den
#
#  Created by Garrett Johnson on 8/2/24.
#  Copyright © 2024
#
#  SPDX-License-Identifier: MIT
#

# Set the -e flag to stop running the script in case a command returns a nonzero exit code.
set -e

# Disable build tool plugin validation.
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
