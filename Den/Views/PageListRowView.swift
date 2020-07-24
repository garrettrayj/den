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
        ZStack {
            if self.editMode?.wrappedValue == .active {
                TextField("Name", text: $page.wrappedName)
            } else {
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
                    
                    Text(page.wrappedName)
                    Spacer()
                    Text(page.unreadCount).font(.caption).padding(.vertical, 4).padding(.horizontal, 8).background(
                        Capsule(style: .circular).foregroundColor(Color(UIColor.secondarySystemBackground))
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
