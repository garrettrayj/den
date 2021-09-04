# Den for RSS

Made for casual surfers and serious wire scanners alike, Den is a simple app for creating dashboards with feeds from your favorite websites.

Catch up on what's happening without all the extras. Browse headlines without ad interuptions, social media distractions, or privacy intrusions. Create as many pages as you like, containing as many feeds as desired, for following anything you want. With Den you have complete control over what you follow.

The dashboard layout for feeds is what sets Den apart from other syndication apps. It's not a feed reader per se, but a feed buffet. It showcases links organized by publisher so one may discover trends and compare sources by skimming through pages. The layout is also ideal for keeping an eye on latest from high volume feeds. The reading experience is powered by Safari or your default system browser depending on device. On phones and tablets, articles open in a Safari view, with an option to automatically enter reader mode. On computers, articles open in the default web browser. On large displays, split-screen with the browser is an especially comfortable window configuration.

Created with a minimalist design philosophy, Den is unobtrusive with some purposefully manual qualities. There are no notifications or badges to attract attention. Refreshing is always triggered by the user so as little as possible is done in the background. Finally, system appearance and accessibility preferences are respected. The overall goal is a clean, crispy app that doesn't weigh down the system or the user.

FEATURES

+ Made for iPhone, iPad, and Mac
Developed from the start for phones, tablets, laptops, and desktops; The interface adapts to look great on screens of all sizes.

+ iCloud Sync
Subscriptions and history on all your devices without yet another account. 

+ RSS, Atom, and JSON Feed
Works with popular formats so the library of compatible feeds is limitless.

+ OPML Import and Export
Bring in subscriptions from other syndication apps and services with ease. Backup or share subscriptions using the same widely used format.

+ Article Search
Quickly get the latest on a particular topic by searching the titles of all items for keywords.

+ History View
Remember previous reads by searching through your history of purple links.

+ Security Check
See which feeds use insecure URLs and check for secure, HTTPS addresses to use instead.


## Release Notes

### Den v1.6

Version 1.6 includes a new Security Check feature and brings back refreshing all pages at once.

- Security Check shows feeds using insecure URLs and provides an easy way to check for HTTPS alternatives.
- The main page list now has it's own refresh button to refresh all feeds. 
- Other improvements to feed refresh responsiveness and progress display.
- General interface and performance improvements.

### Den v1.5

Version 1.5 adds page icon customization.

- Page icon picker with over 300 symbols
- Fixed bug that prevented moving feeds between pages
- Minor interface and performance improvements

### Den v1.4

Version 1.4 enables viewing and managing visited links (history).

- Tab bar for top level views
- History view with search
- Several general bug fixes and improvements

### Den v1.3

Version 1.3 contains several major application performance improvements and many minor user interface enhancements.

- Data is now stored in two databases; one local and one cloud synced. Feed content is kept local, while subscriptions and history are stored in the cloud. Cloud sync may still be disabled in iCloud preferences and the app will work entirely with local databases.
- Images are now downloaded, resized, and saved to locally during feed refresh. The result is better performance and lower memory usage, especially on Mac where a lot images can be in view at once.
- Fixed UI bug that caused dialog boxes to close randomly.
- Fixed UI bug that caused dialog boxes to ignore dark/light mode setting.
- Various other bug fixes, performance improvements, and usability enhancements.

## Technical Documentation

### Foundations

Den is a UIKit application written in Swift and SwiftUI with a good deal of work put towards creating a native experience on MacOS via Catalyst. The major core framework dependencies are Core Data, CloudKit, and Safari Services. Xcode is the only development dependency.

### Open Source Dependencies

- [AEXML](https://github.com/tadija/AEXML) is used for reading and writing OPML files
- [FeedKit](https://github.com/nmdias/FeedKit) for parsing feeds into Swift objects
- [Grid](https://github.com/spacenation/swiftui-grid) for staggard display of widgets (search view)
- [HTMLEntities](https://github.com/Kitura/swift-html-entities) for unescaping `&blah;` in titles and summaries
- [SwiftSoup](https://github.com/scinfu/SwiftSoup) for parsing and cleaning HTML (used to find favicons, preview images, etc.)

### Repository Layout

* `Documents` Design files
* `Den` Main source directory
  * `Entities` Classes for Core Data entities and collections
  * `Models` Data objects and view models
  * `Managers` Global service managers provided to views via `.environmentObject()`
  * `Operations` Classes used to build workflows for `OperationQueue()` (ex. feed ingest)
  * `Views` SwiftUI interface declarations
  * `Extensions` Various patches to core and vendor classes
  * `Utilities` Helper classes for OPML I/0, text transformation, etc.
  * `Misc` Misc artifacts (file type icons, demo feeds)
* `DenTests` TODO
* `DenUITests` TODO
* `DenScreenshots` UI Tests for generating App Store screenshots


## Developer Setup

### Requirements

1. Xcode with Command Line Tools
2. [xcparse](https://github.com/ChargePoint/xcparse) to extract screenshots from test results `brew install chargepoint/xcparse/xcparse`

---

Copyright 2020 Garrett Johnson. All Rights Reserved.
