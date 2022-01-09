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
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var refreshManager: RefreshManager

    @ObservedObject var viewModel: ProfileViewModel

    @Binding var editingPages: Bool
    @Binding var showingSettings: Bool

    @State var searchQuery: String = ""
    @State var showingHistory: Bool = false
    @State var showingSearch: Bool = false

    var body: some View {
        List {
            ForEach(viewModel.profile.pagesArray) { page in
                SidebarPageView(viewModel: PageViewModel(page: page, refreshing: viewModel.refreshing))
                    #if targetEnvironment(macCatalyst)
                    .listRowInsets(EdgeInsets())
                    #endif
            }
        }
        .listStyle(.sidebar)
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            showingSearch = true
        }
        .background(
            Group {
                NavigationLink(isActive: $showingSearch) {
                    SearchView(query: searchQuery)
                } label: {
                    Text("Search")
                }

                NavigationLink(isActive: $showingHistory) {
                    HistoryView()
                } label: {
                    Label("History", systemImage: "clock")
                }

                // Add keyboard shorcut for iOS devices
                #if !targetEnvironment(macCatalyst)
                Button {
                    refreshManager.refresh(profile: viewModel.profile)
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
                .disabled(viewModel.refreshing)
                .buttonStyle(NavigationBarButtonStyle())
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    refreshManager.refresh(profile: viewModel.profile)
                } label: {
                    if viewModel.refreshing {
                        ProgressView().progressViewStyle(NavigationBarProgressStyle())
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(viewModel.refreshing)
                .buttonStyle(NavigationBarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }

            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    NavigationLink {
                        ProfilesView()
                    } label: {
                        Label("Profiles", systemImage: "person.circle")
                    }
                    Spacer()
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
                }.imageScale(.large)
            }
        }
    }
}
