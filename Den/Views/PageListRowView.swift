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
    
    var body: some View {
        NavigationLink(destination: PageView(page: page)) {
            #if targetEnvironment(macCatalyst)
            Image(systemName: "rectangle.grid.2x2")
            #else
            if UIDevice.current.userInterfaceIdiom == .pad {
                Image(systemName: "rectangle.grid.2x2")
            } else {
                Image(systemName: "rectangle.grid.1x2")
            }
            #endif
            
            Text(page.wrappedName).lineLimit(1).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
            Text(String(page.unreadCount))
                .font(.caption)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    Capsule(style: .circular).foregroundColor(Color(UIColor.secondarySystemBackground)
                )
            )
        }
    }
}
