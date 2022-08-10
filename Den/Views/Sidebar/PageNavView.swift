//
//  PageNavView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageNavView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var page: Page

    @State var unreadCount: Int
    @Binding var refreshing: Bool

    var body: some View {
        NavigationLink {
            PageView(page: page, unreadCount: unreadCount, refreshing: $refreshing)
        } label: {
            Label {
                HStack {
                    Text(page.displayName).modifier(SidebarItemLabelTextModifier())

                    Spacer()

                    if editMode?.wrappedValue == .inactive {
                        Text(String(unreadCount)).modifier(CapsuleModifier())
                    }
                }.lineLimit(1)
            } icon: {
                Image(systemName: page.wrappedSymbol).imageScale(.large)
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .pageItemStatus, object: page.objectID)
        ) { notification in
            guard let read = notification.userInfo?["read"] as? Bool else { return }
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
