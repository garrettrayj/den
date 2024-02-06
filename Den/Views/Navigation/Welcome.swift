//
//  Welcome.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct Welcome: View {
    @ObservedObject var profile: Profile

    var body: some View {
        ContentUnavailable {
            Label {
                profile.nameText
            } icon: {
                Image(systemName: "rhombus.fill")
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
