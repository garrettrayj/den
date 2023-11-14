//
//  AppErrorSheet.swift
//  Den
//
//  Created by Garrett Johnson on 7/3/21.
//  Copyright © 2021 Garrett Johnson
//

import SwiftUI

struct AppErrorSheet: View {
    @Binding var message: String?

    var body: some View {
        ContentUnavailable {
            Label {
                Text("Application Error", comment: "Crash view title.")
            } icon: {
                Image(systemName: "xmark.octagon")
            }
        } description: {
            VStack {
                Text(
                    "A critical error occurred. Restart to try again.",
                    comment: "Crash view guidance."
                )

                if let message = message {
                    Text(message)
                }
            }
        }
        .padding()
    }
}
