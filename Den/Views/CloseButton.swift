//
//  CloseButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CloseButton: View {
    let dismiss: DismissAction

    var body: some View {
        Button {
            dismiss()
        } label: {
            Label {
                Text("Close", comment: "Button label.")
            } icon: {
                Image(systemName: "xmark.circle")
            }
        }
        .buttonStyle(.borderless)
    }
}
