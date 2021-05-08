//
//  PageListRowView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Page list item view. Transforms name text labels into text fields when .editMode is active.
 */
struct PageListRowView: View {
    @ObservedObject var page: Page
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        if page.id != nil {
            if mainViewModel.sidebarEditMode == .inactive {
                NavigationLink(
                    destination: PageView(mainViewModel: mainViewModel, page: page),
                    tag: page.id!.uuidString,
                    selection: $mainViewModel.navSelection
                ) {
                    Image(systemName: "square.grid.2x2").sidebarIconView()
                    
                    Text(page.wrappedName)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(String(page.unreadCount))
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            Capsule(style: .circular)
                                .foregroundColor(Color(.systemGroupedBackground))
                        )
                        .accessibility(value: Text("\(page.wrappedName): \(page.unreadCount) unread"))
                }
            } else {
                Text(page.wrappedName)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
