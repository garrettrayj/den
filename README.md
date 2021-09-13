# Den for RSS

A simple app for creating dashboards with feeds from your favorite websites. Made for casual surfers and serious wire scanners alike.

Catch up on what's happening without all the extras. Browse headlines without ad interuptions, social media distractions, or privacy intrusions. Create as many pages as you like, containing as many feeds as desired, for watching any topic. Den is a lightweight and unobtrusive tool for following publishers on your terms.

The dashboard layout is what sets Den apart from other apps. It's not a feed reader per se, but a feed buffet. Drawing inspiration from classic internet start pages, subscriptions are showcased within gadgets. The skimmable grid makes trends aparent and comparing sources natural. The layout is also ideal for unusual feeds. Weather reports, stock alerts, sports scores, and more can all have a place. Reading is powered by Safari or your default browser depending on device. On phones and tablets, articles open in a Safari view, with an option to automatically enter reader mode. On computers, articles open in the default web browser.

FEATURES

+ Made for iPhone, iPad, and Mac
Developed from the start for phones, tablets, laptops, and desktops; The app adapts to look great on all devices.

+ iCloud Sync
Subscriptions and history on all your devices without signing up for yet another account. 

+ RSS, Atom, and JSON Feed
Works with popular formats so the library of compatible feeds is limitless.

+ OPML Import and Export
Bring in subscriptions from other apps with ease. Backup or share feeds using the same dependable format.

+ Article Search
Quickly get the latest on a particular topic by searching the titles of current items.

+ History View
Remember previous reads by searching through your history of visited articles.

+ Security Check
See which feeds use insecure URLs and check for secure alternatives to use instead.


## Release Notes

### Den v1.6.1

Version 1.6.1 includes various bug fixes and minor improvements.

- Fix bugs related to page and feed deletion, reordering
- Increase spacing around toolbar icons


### Den v1.6

Version 1.6 includes a new security check feature and enables refreshing all pages at once.

- Security Check shows feeds using insecure URLs and provides an easy way to check for HTTPS alternatives
- The page list now has it's own button to refresh all pages/feeds in one go
- Improved feed refresh responsiveness and progress display
- Various bug fixes and performance improvements

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
