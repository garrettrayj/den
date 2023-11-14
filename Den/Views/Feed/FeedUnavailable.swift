//
//  FeedUnavailable.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson
//

import SwiftUI

struct FeedUnavailable: View {
    @Environment(\.openURL) private var openURL
    
    let feedData: FeedData?

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

    var title: Text {
        if feedData == nil {
            return Text("No Data", comment: "Feed unavailable message.")
        } else if feedData?.wrappedError != nil {
            return Text("Refresh Error", comment: "Feed unavailable message.")
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
    
    @ViewBuilder
    var actions: some View {
        if feedData?.wrappedError != nil {
            if feedData?.wrappedError == .parsing {
                if let validatorURL = feedData?.feed?.validatorURL {
                    Button {
                        openURL(validatorURL)
                    } label: {
                        Label {
                            Text("Open Validator", comment: "Button label.")
                        } icon: {
                            Image(systemName: "stethoscope")
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    var icon: some View {
        if feedData == nil {
            Image(systemName: "questionmark.folder")
        } else if feedData?.wrappedError != nil {
            Image(systemName: "bolt.horizontal")
        } else {
            Image(systemName: "questionmark.diamond" )
        }
    }
}
