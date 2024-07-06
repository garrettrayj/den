//
//  ApexSection.swift
//  Den
//
//  Created by Garrett Johnson on 1/18/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ApexSection: View {
    var body: some View {
        Section {
            InboxNavLink()
            TrendingNavLink()
            BookmarksNavLink()
        }
    }
}
