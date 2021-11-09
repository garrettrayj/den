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
        #if targetEnvironment(macCatalyst)
        list
        #else
        if viewModel.pageViewModels.count > 0 {
            list.refreshable {
                viewModel.refreshAll()
            }
        } else {
            list
        }
        #endif
    }

    private var list: some View {
        List {
            if editMode?.wrappedValue == .active {
                editListSection
            } else {
                if viewModel.pageViewModels.count > 0 {
                    Divider()
                    pageListSection
                } else {
                    getStartedSection
                }
            }
            Divider()
            otherSection
        }
        .background(
            NavigationLink(tag: "search", selection: $viewModel.activeNav) {
                SearchView(viewModel: viewModel.searchViewModel)
            } label: {
                Label("History", systemImage: "clock")
            }.hidden()
        )
        .environment(\.editMode, editMode)
        .listStyle(SidebarListStyle())
        .navigationTitle("Den")
        .toolbar { toolbar }
    }

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            HStack(spacing: 0) {
                if viewModel.pageViewModels.count > 0 || editMode?.wrappedValue == .active {
                    Button(action: viewModel.createPage) {
                        Label("New Page", systemImage: "plus")
                    }
                }

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
        Section {
            ForEach(viewModel.pageViewModels) { pageViewModel in
                Text(pageViewModel.page.displayName)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 4)
            }
            .onMove(perform: viewModel.movePage)
            .onDelete(perform: viewModel.deletePage)
        }
    }

    private var pageListSection: some View {
        ForEach(viewModel.pageViewModels) { pageViewModel in
            SidebarPageRowView(activeNav: $viewModel.activeNav, pageViewModel: pageViewModel)
                .padding(.leading, 8)
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

    private var otherSection: some View {
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
