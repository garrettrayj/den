//
//  SettingsAboutSection.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsAboutSection: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            LabeledContent {
                Text(verbatim: "\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
                    .font(.callout)
                    .foregroundColor(.secondary)
            } label: {
                Text("Version", comment: "Version info label.")
            }
            
            LabeledContent {
                Button {
                    guard let url = URL(string: "https://den.io") else { return }
                    openURL(url)
                } label: {
                    Text(verbatim: "https://den.io")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("website-button")
            } label: {
                Text("Website", comment: "Website info label.")
            }
        } header: {
            Text("About \(Bundle.main.name)", comment: "Settings section header.")
        } footer: {
            Text(verbatim: Bundle.main.copyright)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .foregroundColor(.secondary)
        }
    }
}
