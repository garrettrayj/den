//
//  HideReaderButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct HideReaderButton: View {
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some View {
        Button {
            browserViewModel.hideReader()
        } label: {
            Label {
                Text("Hide Reader", comment: "Button label.")
            } icon: {
                Image(systemName: "rectangle.portrait.slash")
            }
        }
        .keyboardShortcut("r", modifiers: [.command, .shift], localization: .withoutMirroring)
    }
}
