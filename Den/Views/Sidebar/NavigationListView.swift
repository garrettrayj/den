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
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            refreshManager.refresh(viewModel: viewModel, activePage: subscriptionManager.activePage)
        }
        #endif
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
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .accessibilityIdentifier("settings-button")
                    .disabled(viewModel.refreshing)
                }
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    refreshManager.refresh(
                        viewModel: viewModel,
                        activePage: subscriptionManager.activePage
                    )
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(ToolbarButtonStyle(inBottomBar: true))
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityIdentifier("profile-refresh-button")
                .accessibilityElement()
                .disabled(viewModel.refreshing)

                Spacer()

                VStack {
                    if viewModel.refreshing {
                        ProgressView(viewModel.refreshProgress).progressViewStyle(BottomBarProgressStyle())
                    } else {
                        if viewModel.profile.minimumRefreshedDate != nil {
                            Text("Refreshed \(viewModel.profile.minimumRefreshedDate!.shortShortDisplay())")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }.padding(.horizontal)

                Spacer()

                Button {
                    showingHistory = true
                } label: {
                    Label("History", systemImage: "clock")
                }
                .buttonStyle(ToolbarButtonStyle(inBottomBar: true))
                .accessibilityIdentifier("history-button")
                .disabled(viewModel.refreshing)

            }
        }
    }
}
