//
//  AllSection.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AllSection: View {
    @ObservedObject var profile: Profile

    var body: some View {
        Section {
            InboxNav(profile: profile)
            TrendingNav(profile: profile)
        } header: {
            #if os(macOS)
            Text("All Feeds", comment: "Sidebar section header.")
            #endif
        }
    }
}
