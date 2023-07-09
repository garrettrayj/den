//
//  ImportButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ImportButton: View {
    @Binding var showingImporter: Bool

    var body: some View {
        Button {
            showingImporter = true
        } label: {
            Text("Import", comment: "Button label.")
        }
    }
}
