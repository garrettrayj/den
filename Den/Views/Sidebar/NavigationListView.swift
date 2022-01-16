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

    @ObservedObject var viewModel: ProfileViewModel

    @Binding var showingSettings: Bool

    @State var searchQuery: String = ""
    @State var showingHistory: Bool = false
    @State var showingSearch: Bool = false

    var body: some View {
        List {
            ForEach(viewModel.profile.pagesArray) { page in
                SidebarPageView(
                    viewModel: PageViewModel(
                        page: page,
                        refreshing: viewModel.refreshing
                    )
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            .onMove(perform: viewModel.movePage)
            .onDelete(perform: viewModel.deletePage)
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
                    }.buttonStyle(NavigationBarButtonStyle())
                }

                EditButton()
                    .disabled(refreshManager.isRefreshing)
                    .buttonStyle(NavigationBarButtonStyle())

                if editMode?.wrappedValue == .inactive {
                    Button {
                        refreshManager.refresh(profile: viewModel.profile)
                    } label: {
                        if viewModel.refreshing {
                            ProgressView().progressViewStyle(NavigationBarProgressStyle())
                        } else {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(refreshManager.isRefreshing)
                    .buttonStyle(NavigationBarButtonStyle())
                    .keyboardShortcut("r", modifiers: [.command, .shift])
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
