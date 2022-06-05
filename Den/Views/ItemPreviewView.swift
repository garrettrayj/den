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

    @State private var hovering: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.wrappedTitle)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .topLeading)

            if item.published != nil {
                ItemDateView(date: item.published!, read: item.read)
            }

            if item.feedData?.feed?.showThumbnails == true && item.image != nil {
                previewImage
            }

            if item.summary != nil && item.summary != "" {
                Text("  \(item.summary!)")
                    .font(.callout)
                    .lineLimit(6)
            }
        }
        .padding(12)
        .background(
            hovering ?
                Color(UIColor.quaternarySystemFill) :
                Color(UIColor.secondarySystemGroupedBackground)
        )
        .onHover { hovered in
            hovering = hovered
        }
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
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
            .purgeable(true)
            .placeholder {
                HStack {
                    Image(systemName: "photo").imageScale(.large)
                    Text(item.image?.absoluteString ?? "Unknown address").lineLimit(1).frame(maxWidth: 156)
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
                .frame(maxWidth: .infinity)
                .foregroundColor(.secondary)
                .padding()

            }
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
    }
}
