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
            if profile.feedCount == 1 {
                Text("1 Feed", comment: "Feed count (singular).")
            } else {
                Text("\(profile.feedCount) Feeds", comment: "Feed count (zero/plural).")
            }
        }
    }
}
