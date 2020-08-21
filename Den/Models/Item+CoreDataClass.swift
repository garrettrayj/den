//
//  Item+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit
import HTMLEntities

@objc(Item)
public class Item: NSManagedObject, Identifiable {
    public var wrappedTitle: String {
        get{title ?? "Untitled"}
        set{title = newValue}
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
    
    /**
     Creates item entity from an Atom feed entry
     */
    static func create(atomEntry: AtomFeedEntry, moc managedObjectContext: NSManagedObjectContext) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()

        if let published = atomEntry.published {
            item.published = published
        } else {
            if let published = atomEntry.updated {
                item.published = published
            }
        }
        
        if let title = atomEntry.title {
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            item.title = "Untitled"
        }
        
        item.link = atomEntry.linkURL
        
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
    static func create(rssItem: RSSFeedItem, moc managedObjectContext: NSManagedObjectContext) -> Item {
        let item = Item.init(context: managedObjectContext)
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

        item.link = rssItem.linkURL
        
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
        
        return item
    }
    
    /**
     Creates item entity from a JSON feed item
     */
    static func create(jsonItem: JSONFeedItem, moc managedObjectContext: NSManagedObjectContext) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()
        
        // Prefer RSS pubDate element for published date
        if let published = jsonItem.datePublished {
            item.published = published
        }
        
        if let title = jsonItem.title {
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            item.title = "Untitled"
        }

        if let urlString = jsonItem.url, let link = URL(string: urlString) {
            item.link = link
        } else if let urlString = jsonItem.id, let link = URL(string: urlString) {
            item.link = link
        }
        
        if let imageAttachment = jsonItem.attachments?.first(where: { attachment in
            if let mimeTypeString = attachment.mimeType, let _ = MIMETypes.ImageMIMETypes(rawValue: mimeTypeString) {
                return true
            }
            return false
        }) {
            if let imageString = imageAttachment.url, let image = URL(string: imageString) {
                item.image = image
            }
        }
        
        return item
    }
}
