//
//  WorkspaceView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Master navigation list with links to page views.
*/
struct SidebarView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.editMode) var editMode

    @StateObject var viewModel: ContentViewModel

    /**
     Switch refreshable() on and off depending on environment and page count.
     
         SwiftUI.SwiftUI_UIRefreshControl is not supported when running Catalyst apps in the Mac idiom.
         See UIBehavioralStyle for possible alternatives.
         Consider using a Refresh menu item bound to ⌘-R
     */
    var body: some View {
        Group {
            if editMode?.wrappedValue == .active {
                editingList.environment(\.editMode, editMode)
            } else {
                #if targetEnvironment(macCatalyst)
                navigationList
                #else
                if viewModel.pageViewModels.count > 0 {
                    navigationList.refreshable {
                        viewModel.refreshAll()
                    }
                } else {
                    navigationList
                }
                #endif
            }
        }
        .navigationTitle("Den")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbar }
    }

    private var navigationList: some View {
        List {
            if viewModel.pageViewModels.count > 0 {
                pageListSection
            } else {
                getStartedSection
            }

            moreSection
        }
        .background(
            NavigationLink(tag: "search", selection: $viewModel.activeNav) {
                SearchView(viewModel: viewModel.searchViewModel)
            } label: {
                Label("History", systemImage: "clock")
            }.hidden()
        )
        .listStyle(SidebarListStyle())
        .searchable(
            text: $viewModel.searchViewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            viewModel.showSearch()
            viewModel.searchViewModel.performItemSearch()
        }
    }

    private var editingList: some View {
        List {
            editListSection

            Button(action: viewModel.createPage) {
                Label("New Page", systemImage: "plus.circle")
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            HStack(spacing: 0) {
                if editMode?.wrappedValue == .active {
                    Button {
                        editMode?.wrappedValue = .inactive
                    } label: {
                        Text("Done")
                    }
                }

                if editMode?.wrappedValue == .inactive && viewModel.pageViewModels.count > 0 {
                    Button {
                        editMode?.wrappedValue = .active
                    } label: {
                        Text("Edit")
                    }

                    Button {
                        viewModel.refreshAll()
                    } label: {
                        Label("Refresh All", systemImage: "arrow.clockwise")
                    }
                }
            }.buttonStyle(ToolbarButtonStyle())
        }
    }

    private var editListSection: some View {
        Section(
            header: Text("Pages").font(.title3.weight(.semibold)).padding(.leading, 8)
        ) {
            ForEach(viewModel.pageViewModels) { pageViewModel in
                Text(pageViewModel.page.displayName)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
            .onMove(perform: viewModel.movePage)
            .onDelete(perform: viewModel.deletePage)
        }
        .headerProminence(.increased)
    }

    private var pageListSection: some View {
        Section(
            header: Text("Pages").modifier(SidebarSectionHeaderModifier())
        ) {
            ForEach(viewModel.pageViewModels) { pageViewModel in
                SidebarPageRowView(activeNav: $viewModel.activeNav, pageViewModel: pageViewModel)
                    .padding(.leading, 8)
            }
        }
    }

    private var getStartedSection: some View {
        Section(
            header: Text("Get Started").modifier(SidebarSectionHeaderModifier()),
            footer: Text("or import subscriptions in \(Image(systemName: "gear")) Settings")
        ) {
            Button(action: viewModel.createPage) {
                Label("New Page", systemImage: "plus").padding(.vertical, 4)
            }
            Button(action: viewModel.loadDemo) {
                Label("Load Demo", systemImage: "wand.and.stars").padding(.vertical, 4)
            }
        }
    }

    private var moreSection: some View {
        Group {
            if viewModel.pageViewModels.count > 0 {
                NavigationLink(tag: "history", selection: $viewModel.activeNav) {
                    HistoryView(viewModel: HistoryViewModel(
                        viewContext: viewContext,
                        contentViewModel: viewModel
                    ))
                } label: {
                    Label {
                        Text("History")
                    } icon: {
                        Image(systemName: "clock").foregroundColor(.primary)
                    }
                }.padding(.leading, 8)
            }

            NavigationLink(tag: "settings", selection: $viewModel.activeNav) {
                SettingsView(viewModel: SettingsViewModel(contentViewModel: viewModel))
            } label: {
                Label {
                    Text("Settings")
                } icon: {
                    Image(systemName: "gear").foregroundColor(.primary)
                }

            }.padding(.leading, 8)

        }
    }
}
