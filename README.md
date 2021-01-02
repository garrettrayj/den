# Den for RSS


## App Description

Den is a minimalist feed reader made to deliver the latest headlines without distraction, obfuscation, or manipulation. It helps you follow many sources and discover great content while keeping things in perspective.

Just add widely available RSS feeds to stay up-to-date without all the noise. There is no advertising, notifications, recommendations, comments, or trends; just an alway-fresh buffet of blue links to peruse and enjoy.

### Features

- Compatible with iPhone, iPad, and Mac
- Subscriptions and read items sync across devices with iCloud
- Compatible with RSS, Atom, and JSON feed formats
- Search for current articles by keyword
- OPML import/export for adding and sharing subscriptions
- No additional service subscriptions or accounts
- Light and dark theme options

## Technical Documentation

### Foundations

Den is a UIKit application written in Swift and SwiftUI with a good deal of work put towards creating a native experience on MacOS via Catalyst. The major core framework dependencies are Core Data, CloudKit, and Safari Services. Xcode is the only development dependency.

### Open Source Dependencies

* [AEXML](https://github.com/tadija/AEXML) is used for reading and writing OPML files
* [FeedKit](https://github.com/nmdias/FeedKit) for parsing feeds into Swift objects
* [Grid](https://github.com/spacenation/swiftui-grid) for staggard display of widgets (search view)
* [HTMLEntities](https://github.com/Kitura/swift-html-entities) for unescaping `&blah;` in titles and summaries
* [SwiftSoup](https://github.com/scinfu/SwiftSoup) for parsing and cleaning HTML (used to find favicons, preview images, etc.)
* [URLImage](https://github.com/dmytro-anokhin/url-image) for asynchronous image loading and display in views

### Repository Layout

* `Documents` Design files
* `Den` Main source directory
  * `Misc` Misc artifacts (file type icons, demo feeds)
  * `Managers` Global service managers provided to views via `.environmentObject()`
  * `Operations` Classes used to build workflows for `OperationQueue()` (ex. feed ingest)
  * `Models` Classes for Core Data entities and collections
  * `ViewModels` Classes to encapsulate business logic related to particular views in the application
  * `Views` SwiftUI interface declarations
  * `Extensions` Various patches to core and vendor classes
  * `Utilities` Helper classes for I/0, text transformation, etc.
* `DenTests` TODO
* `DenUITests` TODO
