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
    
    @State private var browserViewModel = BrowserViewModel()

    var body: some View {
        if item.isDeleted || item.id == nil {
            ContentUnavailable {
                Label {
                    Text("Item Removed", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        } else {
            BrowserView(browserViewModel: browserViewModel)
                .toolbar {
                    ItemToolbar(item: item, browserViewModel: browserViewModel)
                }
                .task {
                    browserViewModel.contentRuleLists = await BlocklistManager.getContentRuleLists()
                    browserViewModel.useBlocklists = item.feedData?.feed?.useBlocklists ?? true
                    browserViewModel.useReaderAutomatically = item.feedData?.feed?.readerMode ?? false
                    browserViewModel.allowJavaScript = item.feedData?.feed?.allowJavaScript ?? true

                    browserViewModel.loadURL(url: item.link)
                    
                    HistoryUtility.markItemRead(modelContext: modelContext, item: item)
                }
        }
    }
}
