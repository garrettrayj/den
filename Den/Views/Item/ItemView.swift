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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var item: Item
    @ObservedObject var profile: Profile

    var body: some View {
        Group {
            if item.managedObjectContext == nil || item.feedData?.feed == nil {
                ContentUnavailableView {
                    Label {
                        Text("Item Deleted", comment: "Object removed message.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
            } else {
                BrowserView(
                    url: item.link,
                    readerMode: item.feedData?.feed?.readerMode,
                    extraToolbar: {
                        ToolbarItem {
                            TagsMenu(item: item, profile: profile)
                        }
                    }
                )
                .onAppear {
                    HistoryUtility.markItemRead(context: viewContext, item: item, profile: profile)
                }
            }
        }
    }
}
