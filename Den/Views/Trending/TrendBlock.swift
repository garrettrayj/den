//
//  TrendBlock.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//

import NaturalLanguage
import SwiftUI

import SDWebImageSwiftUI

struct TrendBlock: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.faviconSize) private var faviconSize
    @Environment(\.faviconPixelSize) private var faviconPixelSize

    @ObservedObject var trend: Trend

    private var symbol: String? {
        if trend.tag == NLTag.personalName.rawValue {
            return "person"
        } else if trend.tag == NLTag.organizationName.rawValue {
            return "building"
        } else if trend.tag == NLTag.placeName.rawValue {
            return "mappin.and.ellipse"
        }
        return nil
    }

    private var uniqueFaviconURLs: [URL] {
        trend.feeds.compactMap { feed in
            feed.feedData?.favicon
        }.uniqueElements()
    }

    var body: some View {
        NavigationLink(value: SubDetailPanel.trend(trend)) {
            VStack(alignment: .leading, spacing: 8) {
                trend.titleText.font(.title2.weight(.medium))

                Grid {
                    ForEach(uniqueFaviconURLs.chunked(by: 9), id: \.self) { favicons in
                        GridRow {
                            ForEach(favicons, id: \.self) { favicon in
                                WebImage(
                                    url: favicon,
                                    options: [.decodeFirstFrameOnly, .delayPlaceholder, .lowPriority],
                                    context: [.imageThumbnailPixelSize: faviconPixelSize]
                                ) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    Image(systemName: "dot.radiowaves.up.forward")
                                        .foregroundStyle(.primary)
                                }
                                .frame(width: faviconSize.width, height: faviconSize.height)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                                .grayscale(isEnabled ? 0 : 1)
                            }
                        }
                    }
                }
                .opacity(trend.hasUnread ? 1.0 : 0.5)

                HStack {
                    if let symbol = symbol {
                        Image(systemName: symbol).imageScale(.small)
                    }
                    Text("""
                    \(trend.items.count) items in \(trend.feeds.count) feeds. \
                    \(trend.items.unread().count) unread
                    """, comment: "Trend status line.")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .foregroundStyle(trend.items.unread().isEmpty ? .secondary : .primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .buttonStyle(BasicHoverButtonStyle())
    }
}
