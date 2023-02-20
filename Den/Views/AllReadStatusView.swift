//
//  AllReadStatusView.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AllReadStatusView: View {
    let hiddenCount: Int

    var body: some View {
        Label {
            HStack(spacing: 4) {
                Text("All read").font(.callout)
                Spacer()
                Text("\(hiddenCount) hidden").font(.caption)
            }
        } icon: {
            Image(systemName: "checkmark").imageScale(.small)
        }
        .foregroundColor(.secondary)
        .padding(12)
    }
}
