//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct FeedView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    @AppStorage("FeedPreviewStyle_NoID") private var previewStyle = PreviewStyle.compressed

    init(feed: Feed, profile: Profile, refreshing: Binding<Bool>, hideRead: Binding<Bool>) {
        self.feed = feed
        self.profile = profile

        _refreshing = refreshing
        _hideRead = hideRead

        _previewStyle = AppStorage(
            wrappedValue: PreviewStyle.compressed,
            "FeedPreviewStyle_\(feed.id?.uuidString ?? "NoID")"
        )
    }

    var body: some View {
        if feed.managedObjectContext == nil {
            SplashNote(title: "Feed Deleted", symbol: "slash.circle")
        } else {
            FeedLayout(feed: feed, profile: profile, hideRead: hideRead, previewStyle: previewStyle)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        PreviewStyleButton(previewStyle: $previewStyle)
                        Spacer()
                        NavigationLink(value: DetailPanel.feedSettings(feed)) {
                            Label("Feed Settings", systemImage: "wrench")
                        }
                        .modifier(ToolbarButtonModifier())
                        .accessibilityIdentifier("feed-settings-button")
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        FeedBottomBar(
                            feed: feed,
                            profile: profile,
                            refreshing: $refreshing,
                            hideRead: $hideRead
                        )
                    }
                }
                .onChange(of: feed.page) { _ in
                    dismiss()
                }
                .navigationTitle(feed.wrappedTitle)
        }
    }
}
