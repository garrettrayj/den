//
//  WithItemsUnreadCount.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/24.
//  Copyright © 2024 . All rights reserved.
//

import CoreData
import SwiftUI

struct WithItemsUnreadCount<Content: View>: View {
    @Environment(\.managedObjectContext) private var viewContext

    var scopeObject: NSManagedObject?
    
    @ViewBuilder let content: (Int) -> Content
    
    @State private var viewID = UUID()

    private var unreadCount: Int {
        var predicates: [NSPredicate] = []

        if let feed = scopeObject as? Feed {
            if let feedData = feed.feedData {
                predicates.append(NSPredicate(format: "feedData = %@", feedData))
            } else {
                // Impossible query because there should be no items without FeedData
                predicates.append(NSPredicate(format: "1 = 2"))
            }
        } else if let page = scopeObject as? Page {
            predicates.append(NSPredicate(
                format: "feedData IN %@",
                page.feedsArray.compactMap { $0.feedData }
            ))
        }

        predicates.append(NSPredicate(format: "read = %@", NSNumber(value: false)))
        predicates.append(NSPredicate(format: "extra = %@", NSNumber(value: false)))

        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        let request = Item.fetchRequest()
        request.predicate = compoundPredicate
        
        return (try? viewContext.count(for: request)) ?? 0
    }

    var body: some View {
        content(unreadCount)
            .id(viewID)
            .onReceive(viewContext.publisher(for: \.hasChanges).filter({ $0 == false })) { _ in
                viewID = UUID()
            }
    }
}
