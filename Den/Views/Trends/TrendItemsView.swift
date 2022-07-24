//
//  TrendDetailView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendItemsView: View {
    @EnvironmentObject private var linkManager: LinkManager
    @EnvironmentObject private var refreshManager: RefreshManager
    @AppStorage("trendsHideUnread") var hideRead = false

    var trend: Trend

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                BoardView(width: geometry.size.width, list: trend.items) { item in
                    FeedItemPreviewView(item: item)
                }
                .padding(.top, 8)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    withAnimation {
                        hideRead.toggle()
                    }
                } label: {
                    Label(
                        "Filter Read",
                        systemImage: hideRead ?
                            "line.3.horizontal.decrease.circle.fill"
                            : "line.3.horizontal.decrease.circle"
                    )
                }
                Spacer()
                VStack {
                    Text("\(trend.items.unread().count) Unread").font(.caption)
                }
                Spacer()

                Button {
                    // Toggle all read/unread
                    linkManager.toggleRead(trend: trend)
                } label: {
                    Label(
                        trend.items.unread().isEmpty ? "Mark All Unread": "Mark All Read",
                        systemImage: trend.items.unread().isEmpty ?
                            "checkmark.circle.fill" : "checkmark.circle"
                    )
                }
                .accessibilityIdentifier("mark-all-read-button")
                .disabled(refreshManager.refreshing)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle(trend.wrappedTitle)
    }
}
