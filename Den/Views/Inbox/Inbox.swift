//
//  Inbox.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Inbox: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    @AppStorage("InboxPreviewStyle_NoID") private var previewStyle: PreviewStyle = PreviewStyle.compressed

    init(profile: Profile, hideRead: Binding<Bool>, refreshing: Binding<Bool>) {
        self.profile = profile

        _hideRead = hideRead
        _refreshing = refreshing

        _previewStyle = AppStorage(
            wrappedValue: PreviewStyle.compressed,
            "InboxPreviewStyle_\(profile.id?.uuidString ?? "NoID")"
        )
    }

    var body: some View {
        InboxLayout(profile: profile, hideRead: hideRead, previewStyle: previewStyle)
            .toolbar {
                ToolbarItem {
                    PreviewStyleButton(previewStyle: $previewStyle)
                }
                ToolbarItem {
                    AddFeedButton()
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    InboxBottomBar(profile: profile, refreshing: $refreshing, hideRead: $hideRead)
                }
            }
            .navigationTitle("Inbox")
    }
}
