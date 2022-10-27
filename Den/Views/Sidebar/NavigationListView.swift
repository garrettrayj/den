//
//  NavigationListView.swift
//  Den
//
//  Created by Garrett Johnson on 10/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct NavigationListView: View {
    @Environment(\.persistentContainer) private var persistentContainer
    @Environment(\.managedObjectContext) private var viewContext
    let profile: Profile
    @Binding var selection: Panel?
    @Binding var refreshing: Bool
    @Binding var profileUnreadCount: Int
    @State private var searchInput: String = ""

    let refreshProgress: Progress
    let searchModel: SearchModel

    var body: some View {
        List(selection: $selection) {
            AllItemsNavView(profile: profile, unreadCount: $profileUnreadCount)
            TrendsNavView(profile: profile)
            Section {
                NewPageView(profile: profile, refreshing: $refreshing)
                ForEach(profile.pagesArray) { page in
                    PageNavView(page: page)
                }
                .onMove(perform: movePage)
                .onDelete(perform: deletePage)
            } header: {
                Text("Pages")
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(profile.displayName)
        #if targetEnvironment(macCatalyst)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .searchable(text: $searchInput)
        .onSubmit(of: .search) {
            searchModel.query = searchInput
            selection = .search
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            if !refreshing {
                guard let persistentContainer = persistentContainer else { return }
                RefreshManager.refresh(container: persistentContainer, profile: profile)
            }
        }
        #endif
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .buttonStyle(ToolbarButtonStyle())
                    .disabled(refreshing)
                    .accessibilityIdentifier("edit-page-list-button")
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    selection = .settings
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(ToolbarButtonStyle())
                .accessibilityIdentifier("settings-button")
                .disabled(refreshing)
                Spacer()
                VStack {
                    if refreshing {
                        ProgressView(refreshProgress)
                            .progressViewStyle(BottomBarProgressStyle(progress: refreshProgress))
                    } else if let refreshedDate = profile.minimumRefreshedDate {
                        Text("\(refreshedDate.shortShortDisplay())")
                    } else {
                        #if targetEnvironment(macCatalyst)
                        Text("Press \(Image(systemName: "command")) + R to refresh").imageScale(.small)
                        #else
                        Text("Pull to refresh")
                        #endif
                    }
                }
                .padding(.horizontal, 8)
                .lineLimit(1)
                .font(.caption)
                Spacer()
                Button {
                    guard let persistentContainer = persistentContainer else { return }
                    RefreshManager.refresh(container: persistentContainer, profile: profile)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(ToolbarButtonStyle())
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
