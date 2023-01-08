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
        Section(header: Text("About")) {
            HStack(alignment: .bottom, spacing: 16) {
                Image(uiImage: UIImage(named: "TitleIcon") ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .cornerRadius(8)
                VStack(alignment: .leading) {
                    Text("Den").font(.system(size: 24).weight(.bold))
                    Text("v\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                Spacer()
            }.padding(.vertical, 8)

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
        }
    }
}
