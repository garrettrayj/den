//
//  PageListRowView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPageView: View {
    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        if viewModel.page.id != nil {
            NavigationLink {
                PageView(viewModel: viewModel)
            } label: { rowLabel }
        }
    }

    var rowLabel: some View {
        Label(
            title: {
                HStack {
                    Text(viewModel.page.displayName)
                        #if targetEnvironment(macCatalyst)
                        .padding(.vertical, 8)
                        .padding(.leading, 4)
                        #endif
                    Spacer()
                    if viewModel.refreshing {
                        ProgressView().progressViewStyle(IconProgressStyle())
                    } else {
                        Text(String(viewModel.page.unreadCount))
                            .lineLimit(1)
                            .font(.caption.weight(.medium))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color(UIColor.secondarySystemFill))
                            )
                    }
                }
            },
            icon: { Image(systemName: viewModel.page.wrappedSymbol) }
        )
        .lineLimit(1)
        #if targetEnvironment(macCatalyst)
        .font(.title3)
        .padding(.horizontal, 8)
        #endif
    }
}
