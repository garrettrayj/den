//
//  PageNavView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct PageNavView: View {
    @ObservedObject var page: Page
    
    @State var unreadCount: Int

    var body: some View {
        NavigationLink(value: Panel.page(page)) {
            Label {
                Text(page.displayName).lineLimit(1)
            } icon: {
                Image(systemName: page.wrappedSymbol)
            }
        }
        .badge(unreadCount)
        .onReceive(
            NotificationCenter.default.publisher(for: .itemStatus, object: nil)
        ) { notification in
            guard
                let pageObjectID = notification.userInfo?["pageObjectID"] as? NSManagedObjectID,
                pageObjectID == page.objectID,
                let read = notification.userInfo?["read"] as? Bool
            else {
                return
            }
            unreadCount += read ? -1 : 1
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .feedRefreshed, object: nil)
        ) { notification in
            guard
                let pageObjectID = notification.userInfo?["pageObjectID"] as? NSManagedObjectID,
                pageObjectID == page.objectID
            else {
                return
            }
            unreadCount = page.previewItems.unread().count
        }
        .modifier(URLDropTargetModifier(page: page))
        .accessibilityIdentifier("page-button")
    }
}
