//
//  AllReadSplashNote.swift
//  Den
//
//  Created by Garrett Johnson on 7/24/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AllReadSplashNote: View {
    var body: some View {
        ContentUnavailableView {
            Label {
                Text("All Read")
            } icon: {
                Image(systemName: "checkmark").symbolVariant(.circle)
            }
        } description: {
            Text("Turn off filtering to show hidden items.")
        }
    }
}
