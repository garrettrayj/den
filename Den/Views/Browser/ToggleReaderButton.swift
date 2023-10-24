//
//  ToggleReaderButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/20/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ToggleReaderButton: View {
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some View {
        Button {
            browserViewModel.toggleReader()
        } label: {
            Label {
                Text("Show/Hide Reader", comment: "Button label.")
            } icon: {
                Image(systemName: "doc.plaintext")
            }
        }
        .keyboardShortcut("r", modifiers: [.command, .shift], localization: .withoutMirroring)
    }
}
