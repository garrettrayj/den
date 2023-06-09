//
//  AllRead.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AllRead: View {
    var body: some View {
        Label {
            Text("All Read", comment: "No unread items message.")
        } icon: {
            Image(systemName: "checkmark").imageScale(.small)
        }
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity)
    }
}
