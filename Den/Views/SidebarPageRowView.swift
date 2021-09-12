//
//  PageListRowView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPageRowView: View {
    @ObservedObject var pageViewModel: PageViewModel

    var body: some View {
        NavigationLink(destination: PageView(viewModel: pageViewModel)) {
            Label(
                title: {
                    HStack {
                        Text(pageViewModel.page.displayName).lineLimit(1).padding(.vertical, 4)
                        Spacer()
                        Text(String(pageViewModel.page.unreadCount))
                            .lineLimit(1)
                            .font(.caption)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule(style: .circular)
                                    .foregroundColor(Color(.systemGroupedBackground))
                            )
                    }
                },
                icon: {
                    if pageViewModel.refreshing {
                        ProgressView(value: pageViewModel.refreshFractionCompleted)
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: pageViewModel.page.wrappedSymbol).foregroundColor(.primary)
                    }
                }
            )
        }
    }
}
