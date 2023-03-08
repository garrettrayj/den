//
//  NoFeedsView.swift
//  Den
//
//  Created by Garrett Johnson on 1/31/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NoFeedsView: View {
    var page: Page?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("No Feeds").font(.title)
            Button {
                SubscriptionUtility.showSubscribe(page: page)
            } label: {
                Label("Enter a Web Address", systemImage: "plus.circle")
            }
            .buttonStyle(.bordered)
            .lineLimit(2)
            Text("""
            Or drag and drop a URL, \
            or open a \(Image(systemName: "dot.radiowaves.up.forward")) syndication link, \
            or use the Feed Detector extension in Safari.
            """)
            .font(.body)
            .imageScale(.small)
            .padding(.horizontal)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
}
