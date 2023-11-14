//
//  TrendView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct TrendView: View {
    @ObservedObject var trend: Trend

    @Binding var hideRead: Bool

    var body: some View {
        Group {
            if trend.managedObjectContext == nil || trend.isDeleted {
                ContentUnavailable {
                    Label {
                        Text("Trend Deleted", comment: "Object removed message.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
            } else if let profile = trend.profile {
                WithItems(scopeObject: trend) { items in
                    Group {
                        if trend.items.isEmpty {
                            ContentUnavailable {
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
                            
                        }
                    }
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
        #if os(iOS)
        .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        #endif
    }
}
