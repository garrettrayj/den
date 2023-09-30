//
//  TrendView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendView: View {
    @ObservedObject var trend: Trend

    @Binding var hideRead: Bool

    var body: some View {
        Group {
            if trend.managedObjectContext == nil || trend.isDeleted {
                ContentUnavailableView {
                    Label {
                        Text("Trend Deleted", comment: "Object removed message.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
            } else if let profile = trend.profile {
                WithItems(scopeObject: trend) { items in
                    if trend.items.isEmpty {
                        ContentUnavailableView {
                            Label {
                                Text("No Items", comment: "Content unavailable title.")
                            } icon: {
                                Image(systemName: "questionmark.folder")
                            }
                        }
                    } else if trend.items.unread().isEmpty && hideRead {
                        AllRead(largeDisplay: true)
                    } else {
                        TrendLayout(
                            trend: trend,
                            profile: profile,
                            hideRead: $hideRead,
                            items: items.visibilityFiltered(hideRead ? false : nil)
                        )
                        .toolbar {
                            TrendToolbar(
                                trend: trend,
                                profile: profile,
                                hideRead: $hideRead,
                                items: items
                            )
                        }
                        .navigationTitle(trend.titleText)
                    }
                }
            }
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground))
        #endif
    }
}
