//
//  PageListRowView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPageRowView: View {
    @Binding var activeNav: String?
    @ObservedObject var pageViewModel: PageViewModel

    var body: some View {
        if pageViewModel.page.id != nil {
            NavigationLink(
                tag: pageViewModel.page.id!.uuidString,
                selection: $activeNav
            ) {
                PageView(viewModel: pageViewModel)
            } label: {
                rowLabel
            }
        }
    }

    var rowLabel: some View {
        Label(
            title: {
                HStack {
                    Text(pageViewModel.page.displayName).lineLimit(1)
                    Spacer()
                    Text(String(pageViewModel.page.unreadCount))
                        .lineLimit(1)
                        .font(.footnote.monospacedDigit().weight(.medium))
                        .padding(.trailing, 4)
                }.padding(.vertical, 4)
            },
            icon: {
                if pageViewModel.refreshing {
                    ProgressView(value: pageViewModel.refreshFractionCompleted)
                        .progressViewStyle(IconProgressStyle())
                } else {
                    Image(systemName: pageViewModel.page.wrappedSymbol).foregroundColor(.primary)
                }
            }
        )
    }
}
