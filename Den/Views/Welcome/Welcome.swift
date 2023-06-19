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
        VStack {
            profile.nameText.font(.largeTitle)
        }
        .toolbar {
            WelcomeToolbar(profile: profile)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(isEnabled ? .primary : .secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(GroupedBackground())
    }
}
