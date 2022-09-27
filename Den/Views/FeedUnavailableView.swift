//
//  FeedUnavailableView.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedUnavailableView: View {
    let feedData: FeedData?
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(.headline.weight(.regular))
                        Text(caption).font(.subheadline).foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: symbol)
                        .foregroundColor(symbolColor)
                        .padding(.trailing, 4)
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
                    caption: "Refresh to load feed",
                    useStatusBox: useStatusBox
                )
            } else if let error = feedData?.error {
                StatusMessageView(
                    symbol: "exclamationmark.triangle",
                    title: "Refresh Error",
                    caption: error,
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
