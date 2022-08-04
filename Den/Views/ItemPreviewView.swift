//
//  ItemPreviewView.swift
//  Den
//
//  Created by Garrett Johnson on 12/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct ItemPreviewView: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.wrappedTitle)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .topLeading)

            ItemDateView(date: item.date, read: item.read)

            if item.feedData?.feed?.showThumbnails == true && item.image != nil {
                PreviewImageView(item: item).opacity(item.read ? UIConstants.dimmedImageOpacity : 1.0)
            }

            if item.summary != nil && item.summary != "" {
                Text(item.summary!)
                    .font(.body)
                    .lineLimit(6)
            }
        }
        .padding(12)
        .multilineTextAlignment(.leading)
        .foregroundColor(
            isEnabled ?
                item.read ? .secondary : .primary
            :
                item.read ? Color(UIColor.quaternaryLabel) : Color(UIColor.tertiaryLabel)
        )
        .frame(maxWidth: .infinity)
    }
}
