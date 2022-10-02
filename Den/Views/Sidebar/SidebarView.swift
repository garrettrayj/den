//
//  SidebarView.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct SidebarView: View {
    @Environment(\.editMode) private var editMode
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var profile: Profile
    @Binding var selection: Panel?
    @Binding var refreshing: Bool
    @Binding var profileUnreadCount: Int
    @State private var searchInput: String = ""

    let persistentContainer: NSPersistentContainer
    let refreshProgress: Progress
    let searchModel: SearchModel

    var body: some View {
        List(selection: $selection) {
            if profile.pagesArray.isEmpty {
                StartSectionView(profile: profile)
            } else {
                AllItemsNavView(profile: profile, unreadCount: $profileUnreadCount)
                TrendsNavView(profile: profile)

                Section {
                    ForEach(profile.pagesArray) { page in
                        PageNavView(page: page)
                    }
                    .onMove(perform: movePage)
                    .onDelete(perform: deletePage)
                } header: {
                    Text("Pages")
                    #if targetEnvironment(macCatalyst)
                        .font(.callout).padding(.top, 4)
                    #endif
                }

                NewPageView(profile: profile, refreshing: $refreshing)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(profile.displayName)
        #if targetEnvironment(macCatalyst)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .searchable(
            text: $searchInput,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            searchModel.query = searchInput
            selection = .search
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            if !refreshing {
                RefreshManager.refresh(container: persistentContainer, profile: profile)
            }
        }
        #endif
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .modifier(ToolbarButtonModifier())
                    .disabled(refreshing)
                    .accessibilityIdentifier("edit-page-list-button")
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    selection = .settings
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .modifier(ToolbarButtonModifier())
                .accessibilityIdentifier("settings-button")
                .disabled(refreshing)
                Spacer()
                VStack {
                    if refreshing {
                        ProgressView(refreshProgress)
                            .progressViewStyle(BottomBarProgressStyle(progress: refreshProgress))
                    } else if let refreshedDate = profile.minimumRefreshedDate {
                        Text("Updated \(refreshedDate.shortShortDisplay())")
                    } else {
                        #if targetEnvironment(macCatalyst)
                        Text("Press \(Image(systemName: "command")) + R to refresh").imageScale(.small)
                        #else
                        Text("Pull to refresh")
                        #endif
                    }
                }
                .lineLimit(1)
                .font(.caption)
                Spacer()
                Button {
                    RefreshManager.refresh(container: persistentContainer, profile: profile)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .modifier(ToolbarButtonModifier())
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityIdentifier("profile-refresh-button")
                .disabled(refreshing)
            }
        }
    }

    private func save() {
        do {
            try viewContext.save()
            DispatchQueue.main.async {
                profile.objectWillChange.send()
            }
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }
    }

    private func movePage( from source: IndexSet, to destination: Int) {
        var revisedItems = profile.pagesArray

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
        save()
    }

    private func deletePage(indices: IndexSet) {
        indices.forEach {
            viewContext.delete(profile.pagesArray[$0])
        }
        save()
    }
}
