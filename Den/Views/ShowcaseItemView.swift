//
//  ShowcaseItemView.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseItemView: View {
    @EnvironmentObject var linkManager: LinkManager
    @ObservedObject var item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibility(identifier: "Item Link")

            if item.feedData?.feed?.showThumbnails == true && item.previewUIImage != nil {
                AxisGeometryReader(axis: .horizontal, alignment: .leading) { width in
                    Group {
                        if item.previewUIImage!.size.width < width {
                            Image(uiImage: item.previewUIImage!)
                                .background(Color(UIColor.tertiarySystemGroupedBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
                                )
                                .accessibility(label: Text("Preview Image"))

                        } else {
                            Image(uiImage: item.previewUIImage!)
                                .resizable()
                                .scaledToFit()
                                .background(Color(UIColor.tertiarySystemGroupedBackground))
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
                                )
                                .accessibility(label: Text("Preview Image"))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            if item.summary != nil {
                Text(item.summary!).lineLimit(4)
            }
        }
        .buttonStyle(ItemButtonStyle(read: item.read))
        .padding(12)
        .modifier(GroupBlockModifier())
    }
}
