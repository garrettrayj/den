//
//  NavigationListView.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NavigationListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.editMode) var editMode
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var refreshManager: RefreshManager

    @ObservedObject var profileViewModel: ProfileViewModel
    @StateObject var searchViewModel: SearchViewModel = SearchViewModel()

    var body: some View {
        List {
            ForEach(profileViewModel.profile.pagesArray) { page in
                SidebarPageView(
                    viewModel: PageViewModel(
                        page: page,
                        refreshing: profileViewModel.refreshing
                    )
                )
            }
            .onMove(perform: profileViewModel.movePage)
            .onDelete(perform: profileViewModel.deletePage)
        }
        .listStyle(.sidebar)
        .searchable(
            text: $searchViewModel.input,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            searchViewModel.query = searchViewModel.input
            profileViewModel.showingSearch = true
        }
        .background(
            Group {
                NavigationLink(isActive: $profileViewModel.showingSearch) {
                    SearchView(viewModel: searchViewModel, profile: profileViewModel.profile)
                } label: {
                    Text("Search")
                }

                NavigationLink(isActive: $profileViewModel.showingHistory) {
                    HistoryView(profile: profileViewModel.profile)
                } label: {
                    Label("History", systemImage: "clock")
                }
            }.hidden()
        )
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if editMode?.wrappedValue == EditMode.active {
                    Button(action: profileViewModel.createPage) {
                        Label("New Page", systemImage: "plus").labelStyle(ToolbarLabelStyle())
                    }
                }

                EditButton()
                    .disabled(refreshManager.isRefreshing)
                    #if targetEnvironment(macCatalyst)
                    .padding(.horizontal, 4)
                    #endif

                if editMode?.wrappedValue == .inactive {
                    if refreshManager.isRefreshing {
                        ProgressView().progressViewStyle(ToolbarProgressStyle())
                    } else {
                        Button {
                            refreshManager.refresh(profile: profileViewModel.profile)
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise").labelStyle(ToolbarLabelStyle())
                        }
                        .keyboardShortcut("r", modifiers: [.command, .shift])
                    }
                }
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    profileViewModel.showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }

                Spacer()

                Button {
                    profileViewModel.showingHistory = true
                } label: {
                    Label("History", systemImage: "clock")
                }
            }
        }
    }
}
