#!/usr/bin/osascript

#  WindowSize.scpt
#  Den
#
#  Created by Garrett Johnson on 5/13/23.
#  Copyright © 2022 Garrett Johnson

tell application "System Events" to tell process "Den"
    tell window 1
        # 2752 × 1800
        set size to {1440, 900}
        set position to {50, 50}
    end tell
end tell
