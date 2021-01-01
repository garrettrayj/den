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
    @Binding var editMode: EditMode
    
    var body: some View {
        if page.id != nil {
            if editMode == .inactive {
                NavigationLink(destination: PageView(pageViewModel: PageViewModel(page: page))) {
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
                    
                }.animation(nil)
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
