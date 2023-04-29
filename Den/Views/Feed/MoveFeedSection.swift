//
//  MoveFeedSection.swift
//  Den
//
//  Created by Garrett Johnson on 4/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct MoveFeedSection: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed

    @State private var showingDeleteAlert: Bool = false

    var body: some View {
        Section {
            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Page").modifier(FormRowModifier())
                Spacer()
                pagePicker.labelsHidden().scaledToFit()
            }
            #else
            pagePicker
            #endif
        } header: {
            Text("Move")
        }
        .modifier(ListRowModifier())
    }

    private var pagePicker: some View {
        Picker(selection: $feed.page) {
            ForEach(feed.page?.profile?.pagesArray ?? []) { page in
                Text(page.wrappedName).tag(page as Page?)
            }
        } label: {
            Text("Page").modifier(FormRowModifier())
        }
        .onChange(of: feed.page) { [oldPage = feed.page] newPage in
            self.feed.userOrder = newPage?.feedsUserOrderMax ?? 0 + 1
            NotificationCenter.default.post(
                name: .feedRefreshed,
                object: self.feed.objectID,
                userInfo: ["pageObjectID": oldPage?.objectID as Any]
            )
            NotificationCenter.default.post(
                name: .feedRefreshed,
                object: self.feed.objectID,
                userInfo: ["pageObjectID": newPage?.objectID as Any]
            )
            dismiss()
        }
    }
}
