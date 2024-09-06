//
//  TrendView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.hideRead) private var hideRead
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var trend: Trend

    var body: some View {
        Group {
            if trend.managedObjectContext == nil || trend.isDeleted {
                ContentUnavailable {
                    Label {
                        Text("Trend Removed", comment: "Object removed message.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
            } else {
                Group {
                    if trend.items.isEmpty {
                        ContentUnavailable {
                            Label {
                                Text("No Items", comment: "Content unavailable title.")
                            } icon: {
                                Image(systemName: "questionmark.folder")
                            }
                        }
                    } else if trend.read && hideRead {
                        AllRead(largeDisplay: true)
                    } else {
                        TrendLayout(
                            trend: trend,
                            items: trend.items.visibilityFiltered(hideRead ? false : nil)
                        )
                    }
                }
                .toolbar { toolbarContent }
                .navigationTitle(trend.titleText)
            }
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        #endif
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            ToggleReadFilterButton()
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: trend.items.unread.isEmpty) {
                HistoryUtility.toggleRead(items: trend.items, context: viewContext)
                if hideRead { dismiss() }
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                ToggleReadFilterButton()
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: trend.items.unread.isEmpty) {
                    HistoryUtility.toggleRead(items: trend.items, context: viewContext)
                    if hideRead { dismiss() }
                }
            }
        } else {
            ToolbarItem {
                ToggleReadFilterButton()
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: trend.items.unread.isEmpty) {
                    HistoryUtility.toggleRead(items: trend.items, context: viewContext)
                    if hideRead { dismiss() }
                }
            }
        }
        #endif
    }
}
