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
    var alignment: HorizontalAlignment = .leading

    private struct StatusMessageView: View {
        let symbol: String
        let title: String
        var alignment: HorizontalAlignment
        var caption: String = ""
        var symbolColor: Color = Color.secondary

        var body: some View {
            VStack(alignment: alignment, spacing: 8) {
                Label(title, systemImage: symbol)
                Text(caption).foregroundColor(.secondary)
            }
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            if feedData == nil {
                StatusMessageView(
                    symbol: "questionmark.folder",
                    title: "No Data",
                    alignment: alignment,
                    caption: "Refresh to load content"
                )
            } else if feedData?.error != nil {
                StatusMessageView(
                    symbol: "exclamationmark.triangle",
                    title: "Refresh Error",
                    alignment: alignment,
                    caption: feedData!.error!,
                    symbolColor: .red
                )
            } else if feedData!.itemsArray.count == 0 {
                StatusMessageView(
                    symbol: "questionmark.folder",
                    title: "Feed Empty",
                    alignment: alignment,
                    caption: "No items available"
                )
            } else {
                StatusMessageView(
                    symbol: "questionmark.diamond",
                    title: "Status Unavailable",
                    alignment: alignment
                )
            }
        }
    }
}
