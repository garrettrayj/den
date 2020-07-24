//
//  Item.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit
import SwiftSoup
import HTMLEntities

enum ItemIngressError: Error {
    case missingPubDate, missingTitle, missingLink
}

extension Item: Identifiable {
    public var wrappedTitle: String {
        get{title ?? "Untitled"}
        set{title = newValue}
    }
    
    /**
     Creates item entity from an Atom feed entry
     */
    static func create(in managedObjectContext: NSManagedObjectContext, atomEntry: AtomFeedEntry) throws -> Item {
        let item = self.init(context: managedObjectContext)
        item.id = UUID()

        if let published = atomEntry.published {
            item.published = published
        } else {
            if let published = atomEntry.updated {
                item.published = published
            } else {
                throw ItemIngressError.missingPubDate
            }
        }
        
        if let title = atomEntry.title {
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            item.title = "Untitled"
        }
        
        guard let itemURL = atomEntry.linkURL else {
            throw ItemIngressError.missingLink
        }
        item.link = itemURL

        if let summary = atomEntry.summary?.value {
            item.summary = HTMLCleaner.stripTags(summary)
        }
        
        // Look for preview image in <links> and <media:content>
        if
            let imageLink = atomEntry.links?.first(where: { link in
                guard
                    link.attributes?.rel == "enclosure",
                    let linkMimeType = link.attributes?.type,
                    let _ = MIMETypes.ImageMIMETypes(rawValue: linkMimeType)
                else {
                    return false
                }
                return true
            }),
            let imageURLString = imageLink.attributes?.href,
            let imageURL = URL(string: imageURLString)
        {
            item.image = imageURL
        } else if
            let media = atomEntry.media,
            let imageMediaContent = media.mediaContents?.first(where: { mediaContent in
                guard
                    let mediaMimeType = mediaContent.attributes?.type,
                    let _ = MIMETypes.ImageMIMETypes(rawValue: mediaMimeType)
                else {
                    return false
                }
                
                return true
            }),
            let mediaURLString = imageMediaContent.attributes?.url,
            let mediaURL = URL(string: mediaURLString)
        {
            item.image = mediaURL
        }
        
        return item
    }
    
    /**
     Creates item entity from a RSS feed item
     */
    static func create(in managedObjectContext: NSManagedObjectContext, rssItem: RSSFeedItem) throws -> Item {
        let item = self.init(context: managedObjectContext)
        item.id = UUID()
        
        // Prefer RSS pubDate element for published date
        if let published = rssItem.pubDate {
            item.published = published
        } else {
            // Fallback to Dublin Core metadata for published date (ex. http://feeds.feedburner.com/oatmealfeed does not have pubDate)
            if let published = rssItem.dublinCore?.dcDate {
                item.published = published
            }
        }
        
        if let title = rssItem.title {
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            item.title = "Untitled"
        }
        
        guard let itemURL = rssItem.linkURL else {
            throw ItemIngressError.missingLink
        }
        item.link = itemURL
        
        // Look for preview image in <enclosure> and <media:content>
        if
            let enclosure = rssItem.enclosure,
            let mimeTypeString = enclosure.attributes?.type,
            let _ = MIMETypes.ImageMIMETypes(rawValue: mimeTypeString),
            let enclosureURLString = enclosure.attributes?.url,
            let enclosureURL = URL(string: enclosureURLString)
        {
            item.image = enclosureURL
        } else if
            let media = rssItem.media,
            let imageMediaContent = media.mediaContents?.first(where: { mediaContent in
                guard
                    let mediaMimeType = mediaContent.attributes?.type,
                    let _ = MIMETypes.ImageMIMETypes(rawValue: mediaMimeType)
                else {
                    return false
                }
                
                return true
            }),
            let mediaURLString = imageMediaContent.attributes?.url,
            let mediaURL = URL(string: mediaURLString)
        {
            item.image = mediaURL
        }
        
        if let summary = rssItem.description {
            item.summary = HTMLCleaner.stripTags(summary)
        }
        
        return item
    }
    
    func markRead() {
        if read == true { return }
        read = true
        
        // Update unread count capsules
        self.feed?.page?.objectWillChange.send()
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

extension Collection where Element == Item, Index == Int {
    func delete(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
        indices.forEach { managedObjectContext.delete(self[$0]) }
 
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
