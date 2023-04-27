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

    var body: some View {
        SearchLayout(profile: profile, hideRead: hideRead, query: query)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    SearchBottomBar(profile: profile, hideRead: $hideRead, query: query)
                }
            }
            .navigationTitle("Search")
    }
}
