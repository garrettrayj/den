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
                Label("Add by entering a web address", systemImage: "plus.circle")
            }
            .buttonStyle(.bordered)
            .lineLimit(2)
            Text("""
            Or drag and drop URLs, or open syndication links, \
            or use the Feed Detector Safari extension.
            """).padding(.horizontal)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
}
