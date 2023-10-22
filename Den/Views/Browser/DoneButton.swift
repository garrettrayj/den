//
//  DoneButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DoneButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Text("Done", comment: "Button label.")
                #if os(macOS)
                .font(.body.weight(.medium))
                .padding(.horizontal, 4)
                #endif
        }
    }
}
