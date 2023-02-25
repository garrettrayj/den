//
//  CrashMessageView.swift
//  Den
//
//  Created by Garrett Johnson on 7/3/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CrashMessageView: View {
    var body: some View {
        SplashNoteView(
            title: "Critical Error",
            note: "Restart to try again",
            symbol: "xmark.octagon"
        )
    }
}
