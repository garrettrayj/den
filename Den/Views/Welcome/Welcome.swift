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
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var profile: Profile

    var body: some View {
        VStack(spacing: 8) {
            profile.nameText.font(.largeTitle)

            if profile.feedsArray.count == 1 {
                Text("1 Feed", comment: "Welcome feed count (singular).")
            } else {
                Text("\(profile.feedsArray.count) Feeds", comment: "Welcome feed count (zero/plural).")
            }
        }
        .multilineTextAlignment(.center)
        .foregroundColor(isEnabled ? .primary : .secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
