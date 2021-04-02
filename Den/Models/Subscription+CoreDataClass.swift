//
//  Subscription+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 1/19/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

@objc(Subscription)
public class Subscription: NSManagedObject {
    public var feed: Feed? {
        let values = value(forKey: "feed") as? [Feed]
        
        if let unwrappedValues = values {
            return unwrappedValues.first
        }
        
        return nil
    }
    
    public var urlString: String {
        get{url?.absoluteString ?? ""}
        set{url = URL(string: newValue)}
    }
    
    public var wrappedTitle: String {
        get{title ?? "Untitled"}
        set{title = newValue}
    }
    
    
    static func create(in managedObjectContext: NSManagedObjectContext, page: Page, prepend: Bool = false) -> Subscription {
        let subscription = self.init(context: managedObjectContext)
        subscription.id = UUID()
        subscription.showThumbnails = true
        subscription.page = page
        
        if prepend {
            subscription.userOrder = page.subscriptionsUserOrderMin - 1
        } else {
            subscription.userOrder = page.subscriptionsUserOrderMax + 1
        }
        
        return subscription
    }
    
}
