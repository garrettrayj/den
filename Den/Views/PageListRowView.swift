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
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.editMode) var editMode
    @ObservedObject var page: Page
    @ObservedObject var workspace: Workspace
    
    var body: some View {
        Group {
            if self.editMode?.wrappedValue == .active {
                TextField("Name", text: $page.wrappedName)
            } else {
                NavigationLink(destination: PageView(page: page, updateManager: UpdateManager(refreshable: page, viewContext: viewContext))) {
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
                        .foregroundColor(page.unreadCount > 0 ? Color.accentColor : Color.secondary)
                        .background(
                            Capsule(style: .circular).foregroundColor(Color(UIColor.secondarySystemBackground)
                        )
                    )
                }
            }
        }
    }
}

struct PageListRowView_Previews: PreviewProvider {
    static var previews: some View {
        PageListRowView(page: Page(), workspace: Workspace())
    }
}
