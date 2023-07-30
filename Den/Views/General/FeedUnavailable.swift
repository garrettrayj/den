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
        VStack(spacing: 4) {
            if feedData == nil {
                CardNote(
                    Text("No Data", comment: "Feed unavailable message."),
                    caption: {
                        Text("Refresh to fetch items.", comment: "Feed unavailable message.")
                    },
                    icon: { Image(systemName: "bolt.horizontal") }
                )
            } else if feedData?.wrappedError != nil {
                CardNote(
                    Text("Refresh Failed", comment: "Feed unavailable message."),
                    caption: {
                        if feedData?.wrappedError == .request {
                            Text("Could not fetch data.", comment: "Feed unavailable message.")
                        } else {
                            Text("Unable to parse content.", comment: "Feed unavailable message.")
                        }
                    },
                    icon: { Image(systemName: "exclamationmark.triangle") }
                )
            } else if feedData!.itemsArray.isEmpty {
                CardNote(
                    Text("Feed Empty", comment: "Feed unavailable message."),
                    icon: { Image(systemName: "circle.slash" ).scaleEffect(x: -1, y: 1) }
                )
            } else {
                CardNote(
                    Text("Feed Unavailable", comment: "Feed unavailable message."),
                    icon: { Image(systemName: "questionmark.diamond" ) }
                )
            }
        }
    }
}
