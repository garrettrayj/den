//
//  ItemPreviewView.swift
//  Den
//
//  Created by Garrett Johnson on 12/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

import Kingfisher

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
            VStack(alignment: .leading, spacing: 4) {
                Text(item.wrappedTitle).frame(maxWidth: .infinity, alignment: .topLeading)

                if item.published != nil {
                    ItemDateView(date: item.published!, read: item.read)
                }

                if item.feedData?.feed?.showThumbnails == true && item.image != nil {
                    KFImage(item.image)
                        .placeholder({ _ in
                            Image(systemName: "photo")
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                                .imageScale(.large)
                        })
                        .resizing(referenceSize: ImageSize.preview, mode: .aspectFill)
                        .scaleFactor(UIScreen.main.scale)
                        .fade(duration: 0.3)
                        .resizable()
                        .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                        .frame(
                            maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil,
                            maxHeight: item.imageHeight > 0 ? min(CGFloat(item.imageHeight), 400) : nil,
                            alignment: .top
                        )
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
                        )
                        .accessibility(label: Text("Preview Image"))
                        .opacity(item.read ? 0.65 : 1.0)
                        .padding(.top, 2)
                }

                if item.summary != nil && item.summary != "" {
                    Text("  \(item.summary!)")
                        .font(.callout)
                        .lineLimit(6)
                        .padding(.top, 4)
                }
            }
            .multilineTextAlignment(.leading)
            .padding([.horizontal, .top], 12)
            .padding(.bottom, 12)
            .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(ItemButtonStyle(read: item.read))
        .accessibilityIdentifier("item-preview-button")
    }
}
