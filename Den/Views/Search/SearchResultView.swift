//
//  SearchResultView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SearchResultView: View {
    @ObservedObject var item: Item

    var body: some View {
        ItemActionView(item: item) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.wrappedTitle).font(.headline.weight(.semibold))
                    ItemDateAuthorView(item: item)
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
