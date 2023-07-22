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

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        ZStack {
            if trend.managedObjectContext == nil {
                SplashNote(
                    Text("Trend Deleted", comment: "Object removed message."),
                    icon: { Image(systemName: "xmark") }
                )
            } else if let profile = trend.profile {
                WithItems(scopeObject: trend) { items in
                    TrendLayout(
                        trend: trend,
                        profile: profile,
                        hideRead: $hideRead,
                        items: items.visibilityFiltered(hideRead ? false : nil)
                    )
                    .toolbar(id: "Trend") {
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
