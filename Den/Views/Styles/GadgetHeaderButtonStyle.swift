//
//  GadgetHeaderButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetHeaderButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        GadgetHeaderButton(configuration: configuration)
    }

    private struct GadgetHeaderButton: View {
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {

            configuration.label
                .font(.headline)
                .padding(.leading, 12)
                .padding(.vertical, 8)
                .foregroundColor(
                    isEnabled ? Color.primary : Color.secondary
                )
        }
    }
}
