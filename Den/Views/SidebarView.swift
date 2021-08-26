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
    @Environment(\.presentationMode) var presentation
    @Environment(\.editMode) var editMode
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var crashManager: CrashManager

    @State private var activePageId: String?

    var body: some View {
        List {
            if profileManager.activeProfile?.pagesArray.count ?? 0 > 0 {
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
                    Button(action: createPage) {
                        Label("Create Page", systemImage: "plus")
                    }
                    EditButton()
                }.buttonStyle(ActionButtonStyle())
            }
        }
    }

    private var pageListSection: some View {
        Section {
            ForEach(profileManager.activeProfile!.pagesArray) { page in
                PageListRowView(page: page, activePageId: $activePageId)
            }
            .onMove(perform: self.movePage)
            .onDelete(perform: self.deletePage)
        }
    }

    private var getStartedSection: some View {
        Section(
            header: Text("Get Started"),
            footer: Text("or import subscriptions in settings.")
        ) {
            Button(action: createPage) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create a New Page").fontWeight(.medium).padding(.vertical, 4)
                }
            }
            Button(action: subscriptionManager.loadDemo) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Load Demo Feeds").fontWeight(.medium).padding(.vertical, 4)
                }
            }
        }
    }

    private func createPage() {
        _ = Page.create(in: viewContext, profile: profileManager.activeProfile!)
        do {
            try viewContext.save()
            profileManager.objectWillChange.send()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }

    private func movePage( from source: IndexSet, to destination: Int) {
        guard var revisedItems = profileManager.activeProfile?.pagesArray else { return }

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }

        if viewContext.hasChanges {
            do {
                try viewContext.save()
                profileManager.activeProfile?.objectWillChange.send()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    private func deletePage(indices: IndexSet) {
        profileManager.activeProfile?.pagesArray.delete(at: indices, from: viewContext)
        profileManager.activeProfile?.objectWillChange.send()
    }
}
