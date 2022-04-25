//
//  BackButtonView.swift
//  Den
//
//  Created by Garrett Johnson on 4/24/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BackButtonView: View {
    @Environment(\.dismiss) var dismiss

    let title: String

    var body: some View {
        Button { dismiss() } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.backward").font(.body.weight(.medium))
                Text(title)
            }
        }
        .buttonStyle(ToolbarButtonStyle())
        .padding(.leading, -8)
    }
}
