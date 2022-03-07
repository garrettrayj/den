//
//  SearchResultView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SearchResultView: View {
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
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.wrappedTitle).font(.headline.weight(.semibold))

                    if item.published != nil {
                        Text("\(item.published!, formatter: DateFormatter.mediumShort)")
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
                Spacer()
                if item.feedData?.feed?.showThumbnails == true {
                    thumbnailImage
                }
            }
            .padding(12)
        }
        .buttonStyle(ItemButtonStyle(read: item.read))
        .accessibilityIdentifier("search-result-button")
    }

    private var thumbnailImage: some View {
        item.thumbnailImage?
            .resizable()
            .scaledToFill()
            #if targetEnvironment(macCatalyst)
            .frame(width: 72, height: 48, alignment: .center)
            #else
            .frame(width: 96, height: 64, alignment: .center)
            #endif
            .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
            )
            .accessibility(label: Text("Thumbnail Image"))
    }
}
