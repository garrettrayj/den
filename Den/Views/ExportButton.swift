//
//  ExportButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportButton: View {
    @Binding var showingExporter: Bool

    var body: some View {
        Button {
            showingExporter = true
        } label: {
            Text("Export", comment: "Button label.")
        }
    }
}
