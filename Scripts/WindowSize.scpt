#!/usr/bin/osascript

#  WindowSize.scpt
#  Den
#
#  Created by Garrett Johnson on 5/13/23.
#  Copyright © 2022 Garrett Johnson

tell application "System Events" to tell process "Safari"
    tell window 1
        set size to {1280, 800}
        set position to {50, 50}
    end tell
end tell
