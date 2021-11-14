//
//  PageListRowView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPageView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var refreshManager: RefreshManager

    @Binding var activeNav: String?

    @StateObject var viewModel: PageViewModel

    let refreshAllPublisher = NotificationCenter.default.publisher(for: .refreshAll)

    var body: some View {
        if viewModel.page.id != nil {
            NavigationLink(
                tag: viewModel.page.id!.uuidString,
                selection: $activeNav
            ) {
                PageView(viewModel: viewModel)
            } label: {
                rowLabel
            }.onReceive(refreshAllPublisher) { _ in
                refreshManager.refresh(pageViewModel: viewModel)
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
                    ProgressView(value: viewModel.refreshFractionCompleted)
                        .progressViewStyle(IconProgressStyle())
                } else {
                    Image(systemName: viewModel.page.wrappedSymbol).foregroundColor(.primary)
                }
            }
        )
    }
}
