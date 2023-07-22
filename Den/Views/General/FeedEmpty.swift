//
//  FeedEmpty.swift
//  Den
//
//  Created by Garrett Johnson on 6/26/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedEmpty: View {
    var body: some View {
        Text("Feed Empty", comment: "No items message.")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
    }
}
