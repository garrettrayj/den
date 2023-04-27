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
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Label {
            Text("All Read")
        } icon: {
            Image(systemName: "checkmark")
        }
        .foregroundColor(isEnabled ? .primary : .secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
