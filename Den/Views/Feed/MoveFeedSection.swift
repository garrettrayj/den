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

    var body: some View {
        Section {
            if let profile = feed.page?.profile {
                PagePicker(profile: profile, selection: $feed.page)
                    .onChange(of: feed.page) { [oldPage = feed.page] newPage in
                        self.feed.userOrder = (newPage?.feedsUserOrderMax ?? 0) + 1
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
        } header: {
            Text("Move", comment: "Feed settings section header.")
        }
    }
}
