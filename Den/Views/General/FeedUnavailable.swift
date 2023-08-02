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
    @Environment(\.isEnabled) var isEnabled

    let feedData: FeedData?

    var body: some View {
        CardNote(
            title,
            caption: { caption },
            icon: { icon }
        )
    }

    var title: Text {
        if feedData == nil {
            return Text("No Data", comment: "Feed unavailable message.")
        } else if feedData?.wrappedError != nil {
            return Text("Refresh Failed", comment: "Feed unavailable message.")
        } else if feedData!.itemsArray.isEmpty {
            return Text("Feed Empty", comment: "Feed unavailable message.")
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
            Image(systemName: "bolt.horizontal")
        } else if feedData?.wrappedError != nil {
            Image(systemName: "exclamationmark.triangle")
        } else if feedData!.itemsArray.isEmpty {
            Image(systemName: "circle.slash" )
        } else {
            Image(systemName: "questionmark.diamond" )
        }
    }
}
