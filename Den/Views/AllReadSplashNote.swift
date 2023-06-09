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
        SplashNote(title: Text("All Read", comment: "No unread items message."), symbol: "checkmark")
    }
}
