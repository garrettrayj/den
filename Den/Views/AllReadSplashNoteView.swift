//
//  AllReadSplashNoteView.swift
//  Den
//
//  Created by Garrett Johnson on 7/24/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AllReadSplashNoteView: View {
    let hiddenItemCount: Int

    var body: some View {
        SplashNoteView(
            title: "All Read",
            note: "\(hiddenItemCount) hidden",
            symbol: "checkmark"
        )
    }
}
