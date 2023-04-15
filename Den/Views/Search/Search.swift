//
//  Search.swift
//  Den
//
//  Created by Garrett Johnson on 4/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct Search: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var query: String

    @AppStorage("SearchPreviewStyle_NoID") private var previewStyle = PreviewStyle.compressed

    init(profile: Profile, query: String, hideRead: Binding<Bool>) {
        self.profile = profile
        self.query = query

        _hideRead = hideRead

        _previewStyle = AppStorage(
            wrappedValue: PreviewStyle.compressed,
            "SearchPreviewStyle_\(profile.id?.uuidString ?? "NoID")"
        )
    }

    var body: some View {
        SearchLayout(profile: profile, hideRead: hideRead, previewStyle: previewStyle, query: query)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    PreviewStyleButton(previewStyle: $previewStyle)
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    SearchBottomBar(profile: profile, hideRead: $hideRead, query: query)
                }
            }
            .navigationTitle("Search")
    }
}
