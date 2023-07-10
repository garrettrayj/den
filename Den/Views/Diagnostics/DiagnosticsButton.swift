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
    var body: some View {
        Button {
            NotificationCenter.default.post(name: .showDiagnostics, object: nil, userInfo: nil)
        } label: {
            Label {
                Text("Diagnostics")
            } icon: {
                Image(systemName: "stethoscope")
            }
        }
    }
}
