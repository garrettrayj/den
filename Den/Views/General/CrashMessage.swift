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
        ContentUnavailableView {
            Label {
                Text("Application Error", comment: "Crash view title.")
            } icon: {
                Image(systemName: "xmark.octagon")
            }
        } description: {
            Text(
                "A critical error occurred. Restart to try again.",
                comment: "Crash view guidance."
            ).padding()
        }
        .padding()
    }
}
