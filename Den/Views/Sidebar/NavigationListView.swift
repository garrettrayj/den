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
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @ObservedObject var viewModel: SidebarViewModel
    @Binding var showingSettings: Bool

    @StateObject private var searchViewModel: SearchViewModel = SearchViewModel()

    @State private var showingSearch: Bool = false
    @State private var showingHistory: Bool = false
    @State private var searchInput: String = ""

    var body: some View {
        List {
            NavigationLink {
                TimelineView(
                    viewModel: TimelineViewModel(
                        profile: viewModel.profile,
                        refreshing: viewModel.refreshing
                    )
                )
            } label: {
                Label {
                    Text("Timeline").modifier(SidebarItemLabelTextModifier())
                } icon: {
                    Image(systemName: "calendar.day.timeline.leading").imageScale(.large)
                }
            }
            .accessibilityIdentifier("global-timeline-button")

            NavigationLink {
                TrendsView(
                    viewModel: TrendsViewModel(
                        profile: viewModel.profile,
                        refreshing: viewModel.refreshing
                    )
                )
            } label: {
                Label {
                    Text("Trends").modifier(SidebarItemLabelTextModifier())
                } icon: {
                    Image(systemName: "chart.line.uptrend.xyaxis").imageScale(.large)
                }
            }
            .accessibilityIdentifier("global-trends-button")

            Section {
                ForEach(viewModel.profile.pagesArray) { page in
                    let pageViewModel = PageViewModel(page: page, refreshing: viewModel.refreshing)

                    NavigationLink {
                        PageView(viewModel: pageViewModel)
                    } label: {
                        SidebarPageView(viewModel: pageViewModel).environment(\.editMode, editMode)
                    }
                    .accessibilityIdentifier("page-button")
                }
                .onMove(perform: viewModel.movePage)
                .onDelete(perform: viewModel.deletePage)
            } header: {
                Text("Pages")
                    #if targetEnvironment(macCatalyst)
                    .font(.subheadline)
                    #endif
            }
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
                        ProgressView(viewModel.refreshProgress)
                            .progressViewStyle(BottomBarProgressStyle(progress: viewModel.refreshProgress))
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
                Text("Updated \(viewModel.profile.minimumRefreshedDate!.shortShortDisplay())")
            } else {
                #if targetEnvironment(macCatalyst)
                Text("Press \(Image(systemName: "command")) + R to refresh feeds").imageScale(.small)
                #else
                Text("Pull to refresh feeds")
                #endif
            }
        }.lineLimit(1)
    }
}
