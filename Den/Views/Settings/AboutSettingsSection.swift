//
//  AboutSettingsSection.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AboutSettingsSection: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            HStack {
                Text("Version", comment: "About row label")
                Spacer()
                Text(verbatim: "\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .modifier(FormRowModifier())

            Button {
                guard let url = URL(string: "https://den.io") else { return }
                openURL(url)
            } label: {
                HStack {
                    Text("Website", comment: "About row label")
                    Spacer()
                    Text(verbatim: "https://den.io")
                }
            }
            .buttonStyle(.plain)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("website-button")
        } header: {
            Text("About", comment: "Settings section header")
        } footer: {
            Text(verbatim: "© 2023 Garrett Johnson")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .foregroundColor(.secondary)
        }
        .modifier(ListRowModifier())
    }
}
