//
//  AllReadCompactView.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AllReadCompactView: View {
    var body: some View {
        Label {
            Text("All read")
        } icon: {
            Image(systemName: "checkmark")
        }
        .imageScale(.small)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
    }
}
