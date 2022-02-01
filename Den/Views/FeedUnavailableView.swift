//
//  FeedUnavailableView.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedUnavailableView: View {
    var feedData: FeedData?

    private struct StatusMessageView: View {
        let symbol: String
        let title: String
        var caption: String = ""
        var symbolColor: Color = Color.secondary

        var body: some View {
            HStack(alignment: .top) {
                Image(systemName: symbol)
                    .foregroundColor(symbolColor)
                    .frame(minWidth: 24, alignment: .trailing)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                    Text(caption).font(.callout).foregroundColor(.secondary)
                }
            }
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            if feedData == nil {
                StatusMessageView(
                    symbol: "arrow.clockwise",
                    title: "Feed Empty",
                    caption: "Refresh to load"
                )
            } else if feedData?.error != nil {
                StatusMessageView(
                    symbol: "exclamationmark.triangle",
                    title: "Refresh Error",
                    caption: feedData!.error!,
                    symbolColor: .red
                )
            } else if feedData!.itemsArray.count == 0 {
                StatusMessageView(
                    symbol: "questionmark.folder",
                    title: "Feed Empty",
                    caption: "No items available"
                )
            } else {
                StatusMessageView(
                    symbol: "questionmark.diamond",
                    title: "Status Unavailable"
                )
            }
        }
    }
}
