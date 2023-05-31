//
//  CrashMessage.swift
//  Den
//
//  Created by Garrett Johnson on 7/3/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CrashMessage: View {
    var body: some View {
        SplashNote(
            title: Text("Application Error", comment: "App crashed header"),
            note: Text("A critical error occurred. Restart to try again.", comment: "App crashed guidance"),
            symbol: "xmark.octagon"
        )
    }
}
