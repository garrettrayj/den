//
//  SidebarView.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct SidebarView: View {
    let searchModel: SearchModel

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var contentSelection: ContentPanel?
    @Binding var refreshing: Bool

    @State private var searchInput: String = ""

    var body: some View {
        if profile.pagesArray.isEmpty {
            StartListView(
                profile: profile,
                contentSelection: $contentSelection
            )
        } else {
            NavigationListView(
                profile: profile,
                searchModel: searchModel,
                contentSelection: $contentSelection,
                refreshing: $refreshing
            )
        }
    }
}
