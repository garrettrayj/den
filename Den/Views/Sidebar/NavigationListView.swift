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

    @State var showingSearch: Bool = false
    @State var showingHistory: Bool = false

    @Binding var showingSettings: Bool

    var body: some View {
        List {
            ForEach(profileViewModel.pageViewModels) { pageViewModel in
                SidebarPageView(viewModel: pageViewModel)
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
            showingSearch = true
        }
        .background(
            Group {
                NavigationLink(isActive: $showingSearch) {
                    SearchView(viewModel: searchViewModel, profile: profileViewModel.profile)
                } label: {
                    Text("Search")
                }

                NavigationLink(isActive: $showingHistory) {
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
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }

                Spacer()

                Button {
                    showingHistory = true
                } label: {
                    Label("History", systemImage: "clock")
                }
            }
        }
    }
}
