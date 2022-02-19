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

    @ObservedObject var viewModel: SidebarViewModel
    @Binding var showingSettings: Bool

    @StateObject private var searchViewModel: SearchViewModel = SearchViewModel()

    @State private var showingSearch: Bool = false
    @State private var showingHistory: Bool = false

    var body: some View {
        List {
            ForEach(viewModel.profile.pagesArray) { page in
                NavigationLink {
                    PageView(viewModel: PageViewModel(page: page, refreshing: viewModel.refreshing))
                } label: {
                    SidebarPageView(viewModel: SidebarPageViewModel(
                        page: page,
                        refreshing: viewModel.refreshing
                    ))
                }
                .accessibilityIdentifier("page-button")

            }
            .onMove(perform: viewModel.movePage)
            .onDelete(perform: viewModel.deletePage)
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
                    SearchView(viewModel: searchViewModel, profile: viewModel.profile)
                } label: {
                    Text("Search")
                }

                NavigationLink(isActive: $showingHistory) {
                    HistoryView(profile: viewModel.profile)
                } label: {
                    Label("History", systemImage: "clock")
                }
            }.hidden()
        )
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if editMode?.wrappedValue == EditMode.active {
                    Button(action: viewModel.createPage) {
                        Label("New Page", systemImage: "plus")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .accessibilityIdentifier("new-page-button")
                }

                EditButton()
                    .buttonStyle(ToolbarButtonStyle())
                    .disabled(viewModel.refreshing)
                    .accessibilityIdentifier("edit-page-list-button")

                if editMode?.wrappedValue == .inactive {
                    if viewModel.refreshing {
                        ProgressView().progressViewStyle(ToolbarProgressStyle())
                    } else {
                        Button {
                            refreshManager.refresh(profile: viewModel.profile)
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
