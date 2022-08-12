//
//  SearchResultView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SearchResultView: View {
    @EnvironmentObject private var syncManager: SyncManager

    @ObservedObject var item: Item

    var body: some View {
        ItemActionView(item: item) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.wrappedTitle).font(.headline.weight(.semibold))
                    ItemDateView(date: item.date, read: item.read)
                }
                Spacer()
                if item.feedData?.feed?.showThumbnails == true {
                    ItemThumbnailView(item: item)
                }
            }
            .padding(12)
        }
    }
}
