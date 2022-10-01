//
//  AboutSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AboutSectionView: View {
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
                if let url = URL(string: "https://discord.gg/NS9hMrYrnt") {
                    openURL(url)
                }
            } label: {
                Text("Discord Community")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("website-button")

            Button {
                if let url = URL(string: "mailto:support@devsci.net") {
                    openURL(url)
                }
            } label: {
                Text("Email Support")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("email-support-button")

            Button {
                if let url = URL(string: "https://garrettjohnson.com/privacy/") {
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
