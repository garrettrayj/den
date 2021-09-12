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

    @ObservedObject var viewModel: SidebarViewModel

    var body: some View {
        List {
            if editMode?.wrappedValue == .active {
                editListSection
            } else {
                if viewModel.pageViewModels.count > 0 {
                    pageListSection
                } else {
                    getStartedSection
                }
            }
        }
        .environment(\.editMode, editMode)
        .animation(nil)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Den")
        .toolbar { toolbar }
    }

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            HStack {
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
            }
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
        Section {
            ForEach(viewModel.pageViewModels) { pageViewModel in
                SidebarPageRowView(pageViewModel: pageViewModel)
            }
        }
    }

    private var getStartedSection: some View {
        Section(
            header: Text("Get Started"),
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
}
