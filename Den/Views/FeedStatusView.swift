//
//  FeedStatusView.swift
//  Den
//
//  Created by Garrett Johnson on 1/26/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedStatusView: View {
    let title: String
    var caption: String = ""
    var symbolColor: Color = Color.secondary
    var splashNote: Bool = false

    var body: some View {
        if splashNote {
            SplashNoteView(title: Text(title), caption: Text(.init(caption)))
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                Text(.init(caption)).font(.caption).foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}
