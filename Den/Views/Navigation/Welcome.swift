//
//  Welcome.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Welcome: View {
    @ObservedObject var profile: Profile

    var body: some View {
        ContentUnavailableView {
            Label {
                profile.nameText
            } icon: {
                Image(systemName: "rhombus.fill").foregroundStyle(.tint)
            }
        } description: {
            FeedCount(count: profile.feedsArray.count)
        }
    }
}
