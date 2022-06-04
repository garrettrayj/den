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
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @ObservedObject var viewModel: ProfileViewModel
    @Binding var showingSettings: Bool

    @StateObject private var searchViewModel: SearchViewModel = SearchViewModel()

    @State private var showingSearch: Bool = false
    @State private var showingHistory: Bool = false
    @State private var searchInput: String = ""

    var body: some View {
        List {
            ForEach(viewModel.profile.pagesArray) { page in
                let pageViewModel = PageViewModel(page: page, refreshing: viewModel.refreshing)

                NavigationLink {
                    PageView(viewModel: pageViewModel)
                } label: {
                    SidebarPageView(viewModel: pageViewModel).environment(\.editMode, editMode)
                        .accessibilityIdentifier("page-button")
                        .accessibilityElement()
                }
            }
            .onMove(perform: viewModel.movePage)
            .onDelete(perform: viewModel.deletePage)
        }
        .background(
            NavigationLink(isActive: $showingSearch) {
                SearchView(viewModel: searchViewModel, profile: viewModel.profile)
            } label: {
                Text("Search")
            }.hidden()
        )
        .searchable(
            text: $searchInput,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            searchViewModel.query = searchInput
            showingSearch = true
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            if !viewModel.refreshing {
                refreshManager.refresh(profile: viewModel.profile, activePage: subscriptionManager.activePage)
            }
        }
        #endif
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    if editMode?.wrappedValue == EditMode.active {
                        Button(action: viewModel.createPage) {
                            Label("New Page", systemImage: "plus")
                        }
                        .accessibilityIdentifier("new-page-button")
                    }

                    EditButton()
                        .disabled(viewModel.refreshing)
                        .accessibilityIdentifier("edit-page-list-button")
                }
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .accessibilityIdentifier("settings-button")
                .disabled(viewModel.refreshing)

                Spacer()

                VStack {
                    if viewModel.refreshing {
                        ProgressView(viewModel.refreshProgress).progressViewStyle(BottomBarProgressStyle())
                    } else {
                        refreshedLabel
                    }
                }
                .font(.caption)
                .padding(.horizontal)

                Spacer()

                Button {
                    refreshManager.refresh(
                        profile: viewModel.profile,
                        activePage: subscriptionManager.activePage
                    )
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityIdentifier("profile-refresh-button")
                .accessibilityElement()
                .disabled(viewModel.refreshing)
            }
        }
    }

    var refreshedLabel: some View {
        VStack(alignment: .center, spacing: 0) {
            if viewModel.profile.minimumRefreshedDate != nil {
                Text("\(viewModel.profile.minimumRefreshedDate!.shortShortDisplay())")
                    .lineLimit(1)
            } else {
                #if targetEnvironment(macCatalyst)
                Text("Press \(Image(systemName: "command")) + R to refresh feeds").imageScale(.small)
                #else
                Text("Pull to refresh feeds")
                #endif
            }
        }
    }
}
