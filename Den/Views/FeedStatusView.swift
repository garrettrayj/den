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
    var caption: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
            if let caption = caption {
                Text(.init(caption)).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
