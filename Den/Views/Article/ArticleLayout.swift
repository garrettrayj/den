//
//  ArticleLayout.swift
//  Den
//
//  Created by Garrett Johnson on 9/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ArticleLayout: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.userTint) private var userTint

    @ObservedObject var feed: Feed

    let title: String
    let author: String?
    let date: Date?
    let summaryContent: String?
    let bodyContent: String?
    let link: URL?

    let image: URL?
    let imageWidth: CGFloat
    let imageHeight: CGFloat

    var maxContentWidth: CGFloat {
        CGFloat(700) * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    FeedTitleLabel(feed: feed).font(.title3)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.largeTitle.weight(.semibold))
                            .textSelection(.enabled)
                            .padding(.bottom, 4)
                        if let author = author {
                            Text(author).font(.callout).lineLimit(2)
                        }
                        if let date = date {
                            TimelineView(.everyMinute) { _ in
                                HStack(spacing: 4) {
                                    Text(verbatim: date.formatted(date: .complete, time: .shortened))
                                    Text(verbatim: "(\(date.formatted(.relative(presentation: .numeric))))")
                                }
                                .font(.caption2)
                            }
                        } else {
                            Text("No Date", comment: "Date missing message.")
                        }
                    }

                    if
                        let url = image,
                        !(summaryContent?.contains("<img") ?? false) &&
                        !(bodyContent?.contains("<img") ?? false)
                    {
                        ArticleHero(
                            url: url,
                            width: imageWidth,
                            height: imageHeight
                        )
                    }

                    if bodyContent != nil || summaryContent != nil {
                        ArticleWebView(
                            content: bodyContent ?? summaryContent!,
                            title: title,
                            baseURL: link
                        )
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: maxContentWidth)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
        }
    }
}
