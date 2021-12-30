//
//  SidebarView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Master navigation list with links to page views.
*/
struct SidebarView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var refreshManager: RefreshManager

    @ObservedObject var viewModel: ProfileViewModel

    @State var editingPages: Bool = false
    @State var showingSettings: Bool = false

    /**
     Switch refreshable() on and off depending on environment and page count.
     
         SwiftUI.SwiftUI_UIRefreshControl is not supported when running Catalyst apps in the Mac idiom.
         See UIBehavioralStyle for possible alternatives.
         Consider using a Refresh menu item bound to ⌘-R
     */
    var body: some View {
        Group {
            if editingPages {
                EditingListView(viewModel: viewModel, editingPages: $editingPages)
            } else {
                if viewModel.profile.pagesArray.count > 0 {
                    NavigationListView(
                        viewModel: viewModel,
                        editingPages: $editingPages,
                        showingSettings: $showingSettings
                    )
                    #if !targetEnvironment(macCatalyst)
                    .refreshable {
                        refreshManager.refresh(profile: viewModel.profile)
                    }
                    #endif
                } else {
                    StartListView(viewModel: viewModel, showingSettings: $showingSettings)
                }
            }
        }
        .background(
            NavigationLink(isActive: $showingSettings) {
                SettingsView(viewModel: viewModel)
            } label: {
                Label("Settings", systemImage: "gear")
            }.hidden()
        )
        .navigationTitle("Den")
    }
}
