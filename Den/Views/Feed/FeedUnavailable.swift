//
//  FeedUnavailable.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedUnavailable: View {
    @ObservedObject var feed: Feed

    var largeDisplay: Bool = false

    var body: some View {
        if largeDisplay {
            ContentUnavailable {
                Label {
                    title
                } icon: {
                    icon
                }
            } description: {
                caption
            } actions: {
                actions
            }
            .padding()
        } else {
            CompactContentUnavailable {
                Label {
                    title
                } icon: {
                    icon
                }
            } description: {
                caption
            } actions: {
                actions
            }
        }
    }

    @ViewBuilder
    private var title: some View {
        if let feedData = feed.feedData {
            if feedData.wrappedError == .parsing {
                Text("Parsing Error", comment: "Feed unavailable title.")
            } else if feedData.wrappedError == .request {
                if feedData.httpStatus > 0 {
                    Text(verbatim: """
                    \(feedData.httpStatus) \
                    \(
                        HTTPURLResponse.localizedString(
                            forStatusCode: Int(feedData.httpStatus)
                        )
                        .localizedCapitalized
                    )
                    """)
                } else {
                    Text("Network Error", comment: "Feed unavailable title.")
                }
            } else {
                Text("Unknown Error", comment: "Feed unavailable title.")
            }
        } else {
            Text("No Data", comment: "Feed unavailable title.")
        }
    }

    @ViewBuilder
    private var caption: some View {
        if let feedData = feed.feedData {
            if feedData.wrappedError == .parsing {
                Text("Unable to read feed content.", comment: "Feed unavailable message.")
            } else if feedData.wrappedError == .request {
                if feedData.httpStatus > 0 {
                    Text("Feed unavailable.", comment: "Feed unavailable message.")
                } else {
                    Text("Server unavailable.", comment: "Feed unavailable message.")
                }
            }
        } else {
            Text("Refresh to fetch items.", comment: "Feed unavailable message.")
        }
    }
    
    @ViewBuilder
    private var actions: some View {
        if feed.feedData?.wrappedError != nil {
            if feed.feedData?.wrappedError == .parsing, let validatorURL = feed.validatorURL {
                OpenValidatorButton(url: validatorURL)
            }
        }
    }

    @ViewBuilder
    private var icon: some View {
        if let feedData = feed.feedData {
            if feedData.wrappedError == .request {
                Image(systemName: "network.slash")
            } else {
                Image(systemName: "bolt.horizontal")
            }
        } else {
            Image(systemName: "questionmark.folder")
        }
    }
}
