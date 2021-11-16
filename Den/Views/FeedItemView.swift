//
//  FeedItemView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

import SwiftUI

struct FeedItemView: View {
    @EnvironmentObject var linkManager: LinkManager
    @ObservedObject var item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if item.published != nil {
                Text("\(item.published!, formatter: DateFormatter.mediumShort)")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            Button {
                linkManager.openLink(
                    url: item.link,
                    logHistoryItem: item,
                    readerMode: item.feedData?.feed?.readerMode ?? false
                )
            } label: {
                Text(item.wrappedTitle)
                    .font(.title2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibility(identifier: "Item Link")

            if item.previewImage != nil {
                previewImage
            }

            if item.summary != nil {
                Text(item.summary!).lineLimit(10)
            }
        }
        .buttonStyle(ItemButtonStyle(read: item.read))
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground))
        )
    }

    private var previewImage: some View {
        item.previewImage?
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
            )
            .accessibility(label: Text("Preview Image"))
            .padding(.vertical, 4)
    }

}
