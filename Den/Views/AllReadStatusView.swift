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
    var body: some View {
        Label {
            HStack(spacing: 4) {
                Text("All Read")
            }
        } icon: {
            Image(systemName: "checkmark").imageScale(.small)
        }
        .foregroundColor(Color(.secondaryLabel))
        .padding(12)
    }
}
