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
                    Text(page.displayName)
                        #if targetEnvironment(macCatalyst)
                        .font(.title3)
                        .padding(.leading, 4)
                        #endif
                    Spacer()
                    if refreshing {
                        ProgressView().progressViewStyle(IconProgressStyle())
                    } else {
                        Text(String(page.unreadCount))
                            .lineLimit(1)
                            .font(.caption.weight(.medium))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            #if targetEnvironment(macCatalyst)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            #else
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            #endif
                            .background(
                                Capsule().fill(Color(UIColor.secondarySystemFill))
                            )
                    }

                }
            },
            icon: {
                Image(systemName: page.wrappedSymbol)
            }
        )
        .lineLimit(1)
    }
}
