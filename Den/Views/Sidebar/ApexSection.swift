//
//  ApexSection.swift
//  Den
//
//  Created by Garrett Johnson on 1/18/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct ApexSection: View {
    @ObservedObject var profile: Profile
    
    var body: some View {
        Section {
            InboxNavLink(profile: profile)
            TrendingNavLink(profile: profile)
        }
    }
}
