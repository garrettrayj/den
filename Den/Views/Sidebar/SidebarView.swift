//
//  SidebarView.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct SidebarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var profile: Profile
    @Binding var activeProfile: Profile? // Re-render when active profile changes
    @Binding var selection: Panel?
    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress
    @Binding var profileUnreadCount: Int
    
    @ObservedObject var searchModel: SearchModel

    var body: some View {
        if profile.pagesArray.isEmpty {
            StartListView(
                profile: profile,
                selection: $selection
            )
        } else {
            NavigationListView(
                profile: profile,
                searchModel: searchModel,
                selection: $selection,
                refreshing: $refreshing,
                refreshProgress: $refreshProgress,
                profileUnreadCount: $profileUnreadCount
            )
            .searchable(
                text: $searchModel.query,
                placement: SearchFieldPlacement.navigationBarDrawer(displayMode: .always)
            )
            .onSubmit(of: .search) {
                selection = .search
            }
        }
    }
}
