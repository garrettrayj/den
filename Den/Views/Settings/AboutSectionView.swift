//
//  AboutSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AboutSectionView: View {
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
                openWebsite("https://discord.gg/NS9hMrYrnt")
            } label: {
                Label("Discord Community", systemImage: "person.2.wave.2")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("website-button")

            Button {
                openWebsite("mailto:support@devsci.net")
            } label: {
                Label("Email Support", systemImage: "lifepreserver")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("email-support-button")

            Button {
                openWebsite("https://garrettjohnson.com/apps/")
            } label: {
                Label("Developer Website", systemImage: "house")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("website-button")

            Button {
                openWebsite("https://garrettjohnson.com/privacy/")
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised.slash")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("privacy-policy-button")
        }.modifier(SectionHeaderModifier())
    }

    private func openWebsite(_ address: String) {
        if let url = URL(string: address) {
            UIApplication.shared.open(url)
        }
    }
}
