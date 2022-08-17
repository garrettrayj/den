//
//  NavigationListView.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NavigationListView: View {
    @Environment(\.editMode) private var editMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @ObservedObject var profile: Profile

    @Binding var showingSettings: Bool

    @State private var refreshing: Bool = false
    @State private var showingSearch: Bool = false
    @State private var showingHistory: Bool = false
    @State private var searchInput: String = ""
    @State private var query: String = ""

    var refreshProgress: Progress = Progress()

    var body: some View {
        List {
            AllItemsNavView(
                profile: profile,
                unreadCount: profile.previewItems.unread().count,
                refreshing: $refreshing
            )
            TrendsNavView(profile: profile, refreshing: $refreshing)

            Section {
                ForEach(profile.pagesArray) { page in
                    PageNavView(
                        page: page,
                        unreadCount: page.previewItems.unread().count,
                        refreshing: $refreshing
                    )
                }
                .onMove(perform: movePage)
                .onDelete(perform: deletePage)
            } header: {
                Text("Pages")
                #if targetEnvironment(macCatalyst)
                    .font(.callout).padding(.top, 4)
                #endif
            }
        }
        .background(
            NavigationLink(isActive: $showingSearch) {
                SearchView(profile: profile, query: $query)
            } label: {
                Text("Search")
            }.hidden()
        )
        .searchable(
            text: $searchInput,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search")
        )
        .onSubmit(of: .search) {
            query = searchInput
            showingSearch = true
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            if !refreshing {
                refreshManager.refresh(profile: profile)
            }
        }
        #endif
        .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: profile.objectID)) { _ in
            self.refreshProgress.totalUnitCount = self.refreshUnits
            self.refreshProgress.completedUnitCount = 0
            self.refreshing = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)) { _ in
            self.refreshing = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
            self.refreshProgress.completedUnitCount += 1
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .disabled(refreshing)
                    .accessibilityIdentifier("edit-page-list-button")
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        _ = Page.create(in: viewContext, profile: profile, prepend: true)
                        save()
                    }
                } label: {
                    Label("New Page", systemImage: "plus")
                }
                .disabled(refreshing)
                .accessibilityIdentifier("new-page-button")
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .accessibilityIdentifier("settings-button")
                .disabled(refreshing)

                Spacer()

                VStack {
                    if refreshing {
                        ProgressView(refreshProgress)
                            .progressViewStyle(BottomBarProgressStyle(progress: refreshProgress))
                    } else {
                        refreshedLabel
                    }
                }
                .font(.caption)
                .padding(.horizontal)

                Spacer()

                Button {
                    refreshManager.refresh(profile: profile)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityIdentifier("profile-refresh-button")
                .accessibilityElement()
                .disabled(refreshing)
            }
        }
    }

    var refreshedLabel: some View {
        VStack(alignment: .center, spacing: 0) {
            if profile.minimumRefreshedDate != nil {
                Text("Updated \(profile.minimumRefreshedDate!.shortShortDisplay())")
            } else {
                #if targetEnvironment(macCatalyst)
                Text("Press \(Image(systemName: "command")) + R to refresh").imageScale(.small)
                #else
                Text("Pull to refresh")
                #endif
            }
        }.lineLimit(1)
    }

    private var refreshUnits: Int64 {
        // Number
        Int64(profile.feedsArray.count) + 1
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
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
            profile.objectWillChange.send()
        }
        save()
    }
}
