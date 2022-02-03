//
//  NavigationListView.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NavigationListView: View {
    @Environment(\.editMode) private var editMode
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profileViewModel: ProfileViewModel
    @StateObject private var searchViewModel: SearchViewModel = SearchViewModel()

    @State private var showingSearch: Bool = false
    @State private var showingHistory: Bool = false

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
                        Label("New Page", systemImage: "plus")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .accessibilityIdentifier("new-page-button")
                }

                EditButton()
                    .buttonStyle(ToolbarButtonStyle())
                    .disabled(refreshManager.isRefreshing)
                    .accessibilityIdentifier("edit-page-list-button")

                if editMode?.wrappedValue == .inactive {
                    if refreshManager.isRefreshing {
                        ProgressView().progressViewStyle(ToolbarProgressStyle())
                    } else {
                        Button {
                            refreshManager.refresh(profile: profileViewModel.profile)
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(ToolbarButtonStyle())
                        .keyboardShortcut("r", modifiers: [.command, .shift])
                        .accessibilityIdentifier("profile-refresh-button")
                    }
                }
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(ToolbarButtonStyle())
                .accessibilityIdentifier("settings-button")

                Spacer()

                Button {
                    showingHistory = true
                } label: {
                    Label("History", systemImage: "clock")
                }
                .buttonStyle(ToolbarButtonStyle())
                .accessibilityIdentifier("history-button")
            }
        }
    }
}
