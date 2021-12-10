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
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var refreshManager: RefreshManager

    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var searchViewModel: SearchViewModel

    @Binding var editingPages: Bool
    @Binding var showingSettings: Bool

    @State var showingHistory: Bool = false
    @State var showingSearch: Bool = false

    var body: some View {
        List {
            ForEach(profileViewModel.profile.pagesArray) { page in
                SidebarPageView(viewModel: PageViewModel(page: page, refreshing: profileViewModel.refreshing))
                    #if targetEnvironment(macCatalyst)
                    .listRowInsets(EdgeInsets())
                    #endif
            }
        }
        .listStyle(.sidebar)
        .searchable(
            text: $searchViewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            showingSearch = true
            searchViewModel.performItemSearch()
        }
        .background(
            Group {
                NavigationLink(isActive: $showingSearch) {
                    SearchView(viewModel: searchViewModel)
                } label: {
                    Text("Search")
                }

                NavigationLink(isActive: $showingHistory) {
                    HistoryView(viewModel: HistoryViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager
                    ))
                } label: {
                    Label("History", systemImage: "clock")
                }

                // Add keyboard shorcut for iOS devices
                #if !targetEnvironment(macCatalyst)
                Button {
                    refreshManager.refresh(profile: profileViewModel.profile)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(NavigationBarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command, .shift])
                #endif
            }.hidden()
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingPages = true
                } label: {
                    Text("Edit").lineLimit(1)
                }
                .disabled(profileViewModel.refreshing)
                .buttonStyle(NavigationBarButtonStyle())
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    refreshManager.refresh(profile: profileViewModel.profile)
                } label: {
                    if profileViewModel.refreshing {
                        ProgressView().progressViewStyle(NavigationBarProgressStyle())
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(profileViewModel.refreshing)
                .buttonStyle(NavigationBarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }

            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingHistory = true
                } label: {
                    Label("History", systemImage: "clock")
                }
            }
        }
    }
}
