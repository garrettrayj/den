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
    @ObservedObject var profile: Profile
    
    let searchModel: SearchModel
    
    @Binding var activeProfile: Profile? // Re-render when active profile changes
    @Binding var selection: Panel?
    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress
    
    @State private var searchInput: String = ""

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
                refreshProgress: $refreshProgress
            )
            .searchable(
                text: $searchInput,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .onSubmit(of: .search) {
                searchModel.query = searchInput
                selection = .search
            }
        }
    }
}
