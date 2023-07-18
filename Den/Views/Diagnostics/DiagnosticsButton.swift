//
//  DiagnosticsButton.swift
//  Den
//
//  Created by Garrett Johnson on 7/10/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DiagnosticsButton: View {
    @Binding var detailPanel: DetailPanel?
    
    var body: some View {
        Button {
            detailPanel = .diagnostics
        } label: {
            Label {
                Text("Diagnostics")
            } icon: {
                Image(systemName: "stethoscope")
            }
        }
        .accessibilityIdentifier("ShowDiagnostics")
    }
}
