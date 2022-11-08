# Den

A modern take on the feed powered personalized start page.

- For phones, tablets, laptops, and desktops
- Cloud synchronized profiles
- RSS, Atom, and JSON Feed format support
- OPML import and export

## Installation

Purchase [Den on the App Store](https://apps.apple.com/us/app/den-for-rss/id1528917651) to get both iOS and Mac versions with automatic updates.

Or for Mac only, the [latest release](https://github.com/garrettrayj/den/releases/latest) is available for free download.

## Development Requirements

1. Xcode with Command Line Tools
2. [xcparse](https://github.com/ChargePoint/xcparse) to extract screenshots from test results `brew install chargepoint/xcparse/xcparse`

## Dev Notes

### Feed Issues

- https://chicago.suntimes.com/rss/news/index.xml broken images
- https://lithub.com/feed/ unable to parse

### Testing Background Tasks

https://developer.apple.com/documentation/backgroundtasks/starting_and_terminating_tasks_during_development

e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"net.devsci.den.refresh"]


---

Copyright 2020 Garrett Johnson. All Rights Reserved.
