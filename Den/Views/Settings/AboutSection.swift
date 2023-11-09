//
//  AboutSection.swift
//  Den
//
//  Created by Garrett Johnson on 11/6/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI
import StoreKit

struct AboutSection: View {
    @Environment(\.requestReview) private var requestReview
    
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
                    Image(systemName: "info.square")
                }
            }
            
            Link(destination: URL(string: "https://den.io/help/")!) {
                Label {
                    Text("Help", comment: "Row label.")
                } icon: {
                    Image(systemName: "questionmark.circle")
                }
            }
            
            Button {
                requestReview()
            } label: {
                Label {
                    Text("Leave a Review", comment: "Button label.")
                } icon: {
                    Image(systemName: "square.and.pencil")
                }
            }
        } header: {
            Text("About", comment: "Section header.")
        } footer: {
            Text(Bundle.main.copyright)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom)
                .padding(.top, 4)
        }
    }
}
