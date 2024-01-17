//
//  FeedUnavailable.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson
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

    private var title: Text {
        if feed.feedData == nil {
            return Text("No Data", comment: "Feed unavailable message.")
        } else if feed.feedData?.wrappedError != nil {
            return Text("Refresh Error", comment: "Feed unavailable message.")
        } else {
            return Text("Feed Unavailable", comment: "Feed unavailable message.")
        }
    }

    private var caption: some View {
        Group {
            if feed.feedData == nil {
                Text("Refresh to fetch items.", comment: "Feed unavailable message.")
            } else if feed.feedData?.wrappedError != nil {
                if feed.feedData?.wrappedError == .request {
                    Text("Could not fetch data.", comment: "Feed unavailable message.")
                } else {
                    Text("Unable to parse content.", comment: "Feed unavailable message.")
                }
            }
        }
    }
    
    @ViewBuilder
    private var actions: some View {
        if feed.feedData?.wrappedError != nil {
            if feed.feedData?.wrappedError == .parsing {
                OpenValidatorButton(feed: feed)
            }
        }
    }

    @ViewBuilder
    private var icon: some View {
        if feed.feedData == nil {
            Image(systemName: "questionmark.folder")
        } else if feed.feedData?.wrappedError != nil {
            Image(systemName: "bolt.horizontal")
        } else {
            Image(systemName: "questionmark.diamond" )
        }
    }
}
