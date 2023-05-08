//
//  NoFeeds.swift
//  Den
//
//  Created by Garrett Johnson on 1/31/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NoFeeds: View {
    var page: Page?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("No Feeds").font(.title)
            Button {
                SubscriptionUtility.showSubscribe(page: page)
            } label: {
                Label("Add by Web Address", systemImage: "plus.circle")
            }
            .buttonStyle(.bordered)
            Text("""
            Or drag and drop a feed URL, or open a syndication link, \
            or use the web extension to discover feeds on websites.
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
