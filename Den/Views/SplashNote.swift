//
//  SplashNote.swift
//  Den
//
//  Created by Garrett Johnson on 1/9/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SplashNote: View {
    @Environment(\.isEnabled) private var isEnabled

    let title: String
    var note: String?
    var symbol: String?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            if let symbol = symbol {
                Image(systemName: symbol).font(.system(size: 28))
            }
            Text(title).font(.title)
            if let note = note {
                Text(.init(note))
            }
            Spacer()
        }
        .multilineTextAlignment(.center)
        .foregroundColor(isEnabled ? .primary : .secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(GroupedBackground())
    }
}
