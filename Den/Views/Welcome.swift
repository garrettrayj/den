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
        SplashNote(
            profile.nameText,
            caption: { FeedCount(count: profile.feedsArray.count) },
            hat: { Image(systemName: "rhombus.fill").foregroundStyle(.tint) }
        )
    }
}
