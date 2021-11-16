//
//  PageListRowView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPageView: View {
    @Binding var activeNav: String?
    @StateObject var viewModel: PageViewModel

    var body: some View {
        if viewModel.page.id != nil {
            NavigationLink(
                tag: viewModel.page.id!.uuidString,
                selection: $activeNav
            ) {
                PageView(viewModel: viewModel)
            } label: {
                rowLabel
            }.onReceive(
                NotificationCenter.default.publisher(for: .pageQueued, object: viewModel.page.objectID)
            ) { _ in
                viewModel.refreshState = .loading
            }.onReceive(
                NotificationCenter.default.publisher(for: .pageRefreshed, object: viewModel.page.objectID)
            ) { _ in
                viewModel.refreshState = .waiting
            }
        }
    }

    var rowLabel: some View {
        Label(
            title: {
                HStack {
                    Text(viewModel.page.displayName).lineLimit(1)
                    Spacer()
                    Text(String(viewModel.page.unreadCount))
                        .lineLimit(1)
                        .font(.footnote.monospacedDigit().weight(.medium))
                        .padding(.trailing, 4)
                }
            },
            icon: {
                if viewModel.refreshState == .loading {
                    ProgressView(value: 0).progressViewStyle(IconProgressStyle())
                } else {
                    Image(systemName: viewModel.page.wrappedSymbol).foregroundColor(.primary)
                }
            }
        )
    }
}
