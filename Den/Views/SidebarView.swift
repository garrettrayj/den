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
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @ObservedObject var viewModel: PagesViewModel

    var body: some View {
        List {
            if viewModel.profile.pagesArray.count > 0 {
                pageListSection
            } else {
                getStartedSection
            }
        }
        .environment(\.editMode, editMode)
        .animation(nil)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Den")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: viewModel.createPage) {
                        Label("New Page", systemImage: "plus.square")
                    }
                    Button {
                        editMode?.wrappedValue.toggle()
                    } label: {
                        Text(editMode?.wrappedValue == .active ? "Done" : "Manage")
                    }
                }
            }
        }
    }

    private var pageListSection: some View {
        Section {
            ForEach(viewModel.profile.pagesArray) { page in
                PageListRowView(page: page)
            }
            .onMove(perform: viewModel.movePage)
            .onDelete(perform: viewModel.deletePage)
        }
    }

    private var getStartedSection: some View {
        Section(
            header: Text("Get Started"),
            footer: Text("or import subscriptions in settings.")
        ) {
            Button(action: viewModel.createPage) {
                HStack {
                    Image(systemName: "plus.square")
                    Text("Create a New Page").fontWeight(.medium).padding(.vertical, 4)
                    Spacer()
                }
            }
            Button(action: subscriptionManager.loadDemo) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Load Demo Feeds").fontWeight(.medium).padding(.vertical, 4)
                    Spacer()
                }
            }
        }
    }
}
