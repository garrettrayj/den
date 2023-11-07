//
//  AboutSection.swift
//  Den
//
//  Created by Garrett Johnson on 11/6/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct AboutSection: View {
    var body: some View {
        Section {
            LabeledContent {
                Text(
                    "\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))",
                    comment: "App marketing version and build number."
                )
            } label: {
                Label {
                    Text("Version", comment: "Row label.")
                } icon: {
                    Image(systemName: "info.circle")
                }
            }
            
            LabeledContent {
                Link(destination: URL(string: "https://den.io")!) {
                    Text("https://den.io")
                }
            } label: {
                Label {
                    Text("Website", comment: "Row label.")
                } icon: {
                    Image(systemName: "globe")
                }
            }
        } header: {
            Text("About", comment: "Section header.")
        } footer: {
            Text(Bundle.main.copyright).font(.footnote).foregroundStyle(.secondary)
        }
    }
}
