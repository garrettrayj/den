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
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var refreshManager: RefreshManager

    @ObservedObject var contentViewModel: ContentViewModel
    @ObservedObject var searchViewModel: SearchViewModel

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
            if contentViewModel.pageViewModels.count > 0 {
                pageListSection
            } else {
                getStartedSection
            }

            moreSection
        }
        .background(
            NavigationLink(tag: "search", selection: $contentViewModel.activeNav) {
                SearchView(viewModel: searchViewModel)
            } label: {
                Label("History", systemImage: "clock")
            }.hidden()
        )
        .listStyle(SidebarListStyle())
        .searchable(
            text: $searchViewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            contentViewModel.showSearch()
            searchViewModel.performItemSearch()
        }
    }

    private var editingList: some View {
        List {
            editListSection

            Button(action: contentViewModel.createPage) {
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

                if editMode?.wrappedValue == .inactive && contentViewModel.pageViewModels.count > 0 {
                    Button {
                        editMode?.wrappedValue = .active
                    } label: {
                        Text("Edit")
                    }

                    Button {
                        refreshManager.refresh(contentViewModel: contentViewModel)
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
            ForEach(contentViewModel.pageViewModels) { pageViewModel in
                Text(pageViewModel.page.displayName)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
            .onMove(perform: contentViewModel.movePage)
            .onDelete(perform: contentViewModel.deletePage)
        }
        .headerProminence(.increased)
    }

    private var pageListSection: some View {
        Section(
            header: Text("Pages").modifier(SidebarSectionHeaderModifier())
        ) {
            ForEach(contentViewModel.pageViewModels) { pageViewModel in
                SidebarPageRowView(activeNav: $contentViewModel.activeNav, pageViewModel: pageViewModel)
                    .padding(.leading, 8)
            }
        }
    }

    private var getStartedSection: some View {
        Section(
            header: Text("Get Started").modifier(SidebarSectionHeaderModifier()),
            footer: Text("or import subscriptions in \(Image(systemName: "gear")) Settings")
        ) {
            Button(action: contentViewModel.createPage) {
                Label("New Page", systemImage: "plus").padding(.vertical, 4)
            }
            Button(action: contentViewModel.loadDemo) {
                Label("Load Demo", systemImage: "wand.and.stars").padding(.vertical, 4)
            }
        }
    }

    private var moreSection: some View {
        Group {
            if contentViewModel.pageViewModels.count > 0 {
                NavigationLink(tag: "history", selection: $contentViewModel.activeNav) {
                    HistoryView(viewModel: HistoryViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager
                    ))
                } label: {
                    Label {
                        Text("History")
                    } icon: {
                        Image(systemName: "clock").foregroundColor(.primary)
                    }
                }.padding(.leading, 8)
            }

            NavigationLink(tag: "settings", selection: $contentViewModel.activeNav) {
                SettingsView(viewModel: SettingsViewModel())
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
