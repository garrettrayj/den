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
    @Environment(\.editMode) var editMode
    @ObservedObject var page: Page
    @Binding var pageSelection: String?
    
    var body: some View {
        if page.id != nil {
            if editMode?.wrappedValue == .inactive {
                NavigationLink(
                    destination: PageView(page: page),
                    tag: page.id!.uuidString,
                    selection: $pageSelection
                ) {
                    Label(page.wrappedName, systemImage: "square.grid.2x2")
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
