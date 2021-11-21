//
//  PageListRowView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPageView: View {
    @ObservedObject var page: Page

    @Binding var activeNav: String?
    @State var refreshing: Bool = false

    var body: some View {
        if page.id != nil {
            NavigationLink {
                PageView(page: page, refreshing: $refreshing)
            } label: {
                rowLabel
            }.onReceive(
                NotificationCenter.default.publisher(for: .pageQueued, object: page.objectID)
            ) { _ in
                refreshing = true
            }.onReceive(
                NotificationCenter.default.publisher(for: .pageRefreshed, object: page.objectID)
            ) { _ in
                refreshing = false
            }
        }
    }

    var rowLabel: some View {
        Label(
            title: {
                HStack {
                    Text(page.displayName).lineLimit(1)
                    Spacer()
                    if refreshing {
                        ProgressView().progressViewStyle(IconProgressStyle()).padding(.trailing, 4)
                    } else {
                        Text(String(page.unreadCount))
                            .lineLimit(1)
                            .font(.caption.monospacedDigit().weight(.semibold))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(Color(UIColor.secondarySystemFill))
                            )
                            .padding(.trailing, 4)
                    }

                }
            },
            icon: {
                Image(systemName: page.wrappedSymbol)
            }
        )
    }
}
