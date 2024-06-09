//
//  ItemView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var item: Item
    
    @StateObject private var browserViewModel = BrowserViewModel()

    var body: some View {
        if let url = item.link, item.feedData?.feed != nil {
            BrowserView(
                url: url,
                useBlocklists: item.feedData?.feed?.useBlocklists,
                useReaderAutomatically: item.feedData?.feed?.readerMode,
                allowJavaScript: item.feedData?.feed?.allowJavaScript,
                browserViewModel: browserViewModel
            )
            .toolbar {
                ItemToolbar(item: item, browserViewModel: browserViewModel)
            }
            .onAppear {
                HistoryUtility.markItemRead(context: modelContext, item: item)
            }
        } else {
            ContentUnavailable {
                Label {
                    Text("Item Removed", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
