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
    @State var unreadCount: Int = 0

    var body: some View {
        NavigationLink(value: Panel.page(page.id)) {
            Label {
                HStack {
                    Text(page.displayName).modifier(SidebarItemLabelTextModifier())

                    Spacer()

                    Text(String(unreadCount)).modifier(CapsuleModifier())
                }.lineLimit(1)
            } icon: {
                Image(systemName: page.wrappedSymbol).imageScale(.large)
            }
        }
        .onAppear {
            unreadCount = page.previewItems.unread().count
        }
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
            NotificationCenter.default.publisher(for: .pageRefreshed, object: page.objectID)
        ) { _ in
            unreadCount = page.previewItems.unread().count
        }
        .accessibilityIdentifier("page-button")
    }
}
