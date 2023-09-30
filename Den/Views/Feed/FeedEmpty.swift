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
    var largeDisplay: Bool = false

    var body: some View {
        if largeDisplay {
            ContentUnavailableView {
                Label {
                    Text("Feed Empty", comment: "Content unavailable title.")
                } icon: {
                    Image(systemName: "questionmark.folder")
                }
            }
        } else {
            CardNote(
                Text("Feed Empty", comment: "No items message."),
                icon: {
                    Image(systemName: "questionmark.folder")
                }
            )
        }
    }
}
