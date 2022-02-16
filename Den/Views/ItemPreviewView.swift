//
//  ItemPreviewView.swift
//  Den
//
//  Created by Garrett Johnson on 12/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemPreviewView: View {
    @EnvironmentObject private var linkManager: LinkManager
    @ObservedObject var item: Item

    var body: some View {
        Button {
            linkManager.openLink(
                url: item.link,
                logHistoryItem: item,
                readerMode: item.feedData?.feed?.readerMode ?? false
            )
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.wrappedTitle).frame(maxWidth: .infinity, alignment: .topLeading)

                if item.published != nil {
                    ItemDateView(date: item.published!, read: item.read)
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
                        .opacity(item.read ? 0.65 : 1.0)
                }

                if item.summary != nil && item.summary != "" {
                    Text(item.summary!)
                        .font(.body)
                        .lineLimit(6)
                        .padding(.top, 2)
                }
            }
            .multilineTextAlignment(.leading)
            .padding([.horizontal, .top], 12)
            .padding(.bottom, 16)
            .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(ItemButtonStyle(read: item.read))
        .accessibilityIdentifier("item-preview-button")
    }
}
