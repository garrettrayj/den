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
                previewImage
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

    private var previewImage: some View {
        WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.preview])
            .resizable()
            .placeholder {
                imagePlaceholder
            }
            .aspectRatio(item.imageAspectRatio, contentMode: .fit)
            .frame(
                maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil,
                maxHeight: item.imageHeight > 0 ? CGFloat(item.imageHeight) : nil
            )
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
            )
            .accessibility(label: Text("Preview Image"))
            .opacity(item.read ? 0.65 : 1.0)
    }

    private var imagePlaceholder: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(item.imageAspectRatio ?? 3/2, contentMode: .fit)
                .foregroundColor(.clear)

            HStack {
                Image(systemName: "photo").imageScale(.large)
                Text(item.image?.absoluteString ?? "Unknown address").lineLimit(1)
                Spacer()
                Button {
                    UIPasteboard.general.string = item.image?.absoluteString
                } label: {
                    Label("Copy Image URL", systemImage: "doc.on.doc")
                        .imageScale(.small)
                        .labelStyle(.iconOnly)
                }
                .accessibilityIdentifier("image-copy-url-button")
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding()
        }
    }
}
