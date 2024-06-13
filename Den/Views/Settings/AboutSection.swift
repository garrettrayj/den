//
//  AboutSection.swift
//  Den
//
//  Created by Garrett Johnson on 11/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import StoreKit

struct AboutSection: View {
    // https://github.com/apple/swift/issues/72181
    // @Environment(\.requestReview) private var requestReview
    
    var body: some View {
        Section {
            ViewThatFits {
                LabeledContent {
                    versionInfo
                } label: {
                    versionLabel
                }
                
                VStack(alignment: .leading) {
                    versionLabel
                    versionInfo
                }
            }
            
            Link(destination: URL(string: "https://den.io/help/")!) {
                Label {
                    Text("Help", comment: "Button label.")
                } icon: {
                    Image(systemName: "questionmark.circle")
                }
            }
            
            /*
            Button {
                requestReview()
            } label: {
                Label {
                    Text("Leave a Review", comment: "Button label.")
                } icon: {
                    Image(systemName: "square.and.pencil")
                }
            }
            */
            
            NavigationLink {
                Acknowledgements()
            } label: {
                Label {
                    Text("Acknowledgements")
                } icon: {
                    Image(systemName: "rosette")
                }
            }
        } header: {
            Text("About \(Bundle.main.name)", comment: "Settings section header.")
        } footer: {
            Text(Bundle.main.copyright)
        }
    }
    
    private var versionLabel: some View {
        Label {
            Text("Version", comment: "About row label.")
        } icon: {
            Image(systemName: "info.square")
        }
        .lineLimit(1)
    }
    
    private var versionInfo: some View {
        Text(verbatim: "\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
            .font(.callout)
            .foregroundStyle(.secondary)
    }
}
