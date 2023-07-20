#!/bin/zsh

version="$MARKETING_VERSION"
build="$CURRENT_PROJECT_VERSION"

/usr/libexec/PlistBuddy \
    -x -c "set PreferenceSpecifiers:4:DefaultValue $version ($build)" \
    "${SRCROOT}/Settings.bundle/Root.plist"
