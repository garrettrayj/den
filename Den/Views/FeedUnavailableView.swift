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
    var useStatusBox: Bool = false

    private struct StatusMessageView: View {
        let symbol: String
        let title: String
        var caption: String = ""
        var symbolColor: Color = Color.secondary
        var useStatusBox: Bool = false

        var body: some View {
            if useStatusBox {
                StatusBoxView(message: Text(title), caption: Text(caption), symbol: symbol)
            } else {
                Label {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                        Text(caption).foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: symbol).foregroundColor(symbolColor)
                }
            }
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            if feedData == nil {
                StatusMessageView(
                    symbol: "questionmark.folder",
                    title: "No Data",
                    caption: "Refresh to load content",
                    useStatusBox: useStatusBox
                )
            } else if feedData?.error != nil {
                StatusMessageView(
                    symbol: "exclamationmark.triangle",
                    title: "Refresh Error",
                    caption: feedData!.error!,
                    symbolColor: .red,
                    useStatusBox: useStatusBox
                )
            } else if feedData!.itemsArray.isEmpty {
                StatusMessageView(
                    symbol: "questionmark.folder",
                    title: "Feed Empty",
                    caption: "No items to show",
                    useStatusBox: useStatusBox
                )
            } else {
                StatusMessageView(
                    symbol: "questionmark.diamond",
                    title: "Status Unavailable",
                    useStatusBox: useStatusBox
                )
            }
        }
    }
}
