//
//  FeedUnavailable.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedUnavailable: View {
    let feedData: FeedData?

    var largeDisplay: Bool = false

    var body: some View {
        if largeDisplay {
            ContentUnavailableView {
                Label {
                    title
                } icon: {
                    icon
                }
            } description: {
                caption
            }
        } else {
            CardNote(
                title,
                caption: { caption },
                icon: { icon }
            )
        }
    }

    var title: Text {
        if feedData == nil {
            return Text("No Data", comment: "Feed unavailable message.")
        } else if feedData?.wrappedError != nil {
            return Text("Refresh Failed", comment: "Feed unavailable message.")
        } else {
            return Text("Feed Unavailable", comment: "Feed unavailable message.")
        }
    }

    var caption: some View {
        Group {
            if feedData == nil {
                Text("Refresh to fetch items.", comment: "Feed unavailable message.")
            } else if feedData?.wrappedError != nil {
                if feedData?.wrappedError == .request {
                    Text("Could not fetch data.", comment: "Feed unavailable message.")
                } else {
                    Text("Unable to parse content.", comment: "Feed unavailable message.")
                }
            }
        }
    }

    var icon: Image {
        if feedData == nil {
            return Image(systemName: "circle.slash")
        } else if feedData?.wrappedError != nil {
            return Image(systemName: "bolt.horizontal")
        } else {
            return Image(systemName: "questionmark.diamond" )
        }
    }
}
