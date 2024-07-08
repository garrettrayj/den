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
    @Bindable var trend: Trend

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        Group {
            if trend.isDeleted || trend.id == nil {
                ContentUnavailable {
                    Label {
                        Text("Trend Removed", comment: "Object removed message.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
            } else {
                Group {
                    if let items = trend.items, items.isEmpty {
                        ContentUnavailable {
                            Label {
                                Text("No Items", comment: "Content unavailable title.")
                            } icon: {
                                Image(systemName: "questionmark.folder")
                            }
                        }
                    } else if trend.read == true && hideRead {
                        AllRead(largeDisplay: true)
                    } else {
                        TrendLayout(
                            trend: trend,
                            items: trend.items?.visibilityFiltered(hideRead ? false : nil) ?? []
                        )
                    }
                }
                .toolbar {
                    TrendToolbar(
                        trend: trend,
                        items: trend.items ?? []
                    )
                }
                .navigationTitle(trend.titleText)
            }
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        #endif
    }
}
