//
//  ShowReaderButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/20/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ShowReaderButton: View {
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some View {
        Button {
            browserViewModel.showReader()
        } label: {
            Label {
                Text("Show Reader", comment: "Button label.")
            } icon: {
                Image(systemName: "doc.plaintext")
            }
        }
        .keyboardShortcut("r", modifiers: [.command, .shift], localization: .withoutMirroring)
        .accessibilityLabel("ShowReader")
    }
}
