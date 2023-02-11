//
//  AboutSettingsSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AboutSettingsSectionView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            HStack {
                Text("Den").font(.title3)
                Spacer()
                Text("Version \(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
                    .foregroundColor(.secondary)
            }
            .modifier(FormRowModifier())

            Button {
                if let url = URL(string: "https://den.io") {
                    openURL(url)
                }
            } label: {
                Text("Website")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("website-button")

            Button {
                if let url = URL(string: "https://den.io/privacy/") {
                    openURL(url)
                }
            } label: {
                Text("Privacy Policy")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("privacy-policy-button")
        } header: {
            Text("About")
        }
    }
}
