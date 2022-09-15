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
        ZStack(alignment: .topLeading) {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(aspectRatio, contentMode: .fit)
                .foregroundColor(.clear)

            HStack {
                Image(systemName: "photo").imageScale(.large)
                Text(imageURL?.absoluteString ?? "Unknown address").lineLimit(1)
                Spacer()
                Button {
                    UIPasteboard.general.string = imageURL?.absoluteString
                } label: {
                    Label("Copy Image URL", systemImage: "doc.on.doc")
                        .imageScale(.small)
                        .labelStyle(.iconOnly)
                }
                .accessibilityIdentifier("image-copy-url-button")
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(padding)
        }
    }
}
