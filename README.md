# Den for RSS

## App Description

Den is a feed reader created to deliver the latest headlines without distraction, obfuscation, or manipulation.

Just add widely available RSS feeds to stay up-to-date without all the noise. There is no advertising, notifications, recommendations, comments, or trends; just a buffet of links from just the publishers you choose.

- Compatible with iPhone, iPad, and Mac
- Subscriptions and read items sync across devices with iCloud
- Compatible with RSS, Atom, and JSON feed formats
- Search for items and subscriptions
- OPML import and export for adding and sharing subscriptions
- Light and dark theme options

## Release Notes

### Den 1.3

Version 1.3 includes major application performance improvements and minor UI bugfixes.

- Data is stored in two databases; local and cloud synced. Feed content is kept in local, while subscriptions and visits are stored in the cloud database. Cloud sync may still be disabled in iCloud preferences and the app will work entirely with local databases.
- Images are downloaded, resized, and saved in a local cache during feed refresh.
- Fixed UI bug that caused dialog boxes to close randomly.
- Fixed UI bug that caused dialog boxes to ignore dark/light mode setting.

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
