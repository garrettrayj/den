//
//  ImagePlaceholderView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemImagePlaceholderView: View {
    let imageURL: URL?
    let aspectRatio: CGFloat?
    var padding: CGFloat = .zero

    var body: some View {
        HStack {
            Image(systemName: "photo")
            Text(imageURL?.absoluteString ?? "Unknown address").lineLimit(1).font(.caption)
            Spacer()
            Button {
                UIPasteboard.general.string = imageURL?.absoluteString
            } label: {
                Label {
                    Text("Copy Image URL")
                } icon: {
                    Image(systemName: "doc.on.doc").imageScale(.small)
                }.labelStyle(.iconOnly)
            }
            .accessibilityIdentifier("image-copy-url-button")
        }
        .foregroundColor(.secondary)
        .padding(padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .aspectRatio(aspectRatio, contentMode: .fill)
    }
}
