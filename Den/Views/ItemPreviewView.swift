//
//  ItemPreviewView.swift
//  Den
//
//  Created by Garrett Johnson on 12/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemPreviewView: View {
    @EnvironmentObject var linkManager: LinkManager
    @ObservedObject var item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                linkManager.openLink(
                    url: item.link,
                    logHistoryItem: item,
                    readerMode: item.feedData?.feed?.readerMode ?? false
                )
            } label: {
                Text(item.wrappedTitle)
            }
            .buttonStyle(ItemButtonStyle(read: item.read))
            .accessibility(identifier: "Item Link")

            if item.published != nil {
                Text("\(item.published!, formatter: DateFormatter.mediumShort)")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            if item.feedData?.feed?.showThumbnails == true {
                item.previewImage?
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: CGFloat(item.imageWidth), maxHeight: CGFloat(item.imageHeight))
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
                    )
                    .accessibility(label: Text("Preview Image"))
            }

            if item.summary != nil && item.summary != "" {
                Text(item.summary!).lineLimit(6)
            }
        }
        .padding([.horizontal, .bottom])
    }
}
