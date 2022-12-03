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
    @Environment(\.persistentContainer) private var container
    @Environment(\.editMode) private var editMode
    
    @ObservedObject var profile: Profile
    @ObservedObject var appState: AppState
    
    @Binding var selection: Panel?
    
    let refreshProgress: Progress = Progress()

    var body: some View {
        List(selection: $selection) {
            InboxNavView(profile: profile, unreadCount: profile.previewItems.unread().count)
            TrendsNavView(profile: profile)
            Section {
                NewPageView(profile: profile)
                ForEach(profile.pagesArray) { page in
                    PageNavView(page: page, unreadCount: page.previewItems.unread().count)
                }
                .onMove(perform: movePage)
                .onDelete(perform: deletePage)
            } header: {
                Text("Pages")
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(profile.displayName)
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            if !appState.refreshing {
                await RefreshUtility.refresh(container: container, profile: profile)
            }
        }
        #endif
        .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: profile.objectID)) { _ in
            Haptics.mediumImpactFeedbackGenerator.impactOccurred()
            refreshProgress.totalUnitCount = Int64(profile.feedsArray.count)
            refreshProgress.completedUnitCount = 0
            appState.refreshing = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
            refreshProgress.completedUnitCount += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .pagesRefreshed)) { _ in
            refreshProgress.completedUnitCount += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)) { _ in
            appState.refreshing = false
            profile.objectWillChange.send()
            Haptics.notificationFeedbackGenerator.notificationOccurred(.success)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                editButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                addFeedButton
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    selection = .settings
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(ToolbarButtonStyle())
                .accessibilityIdentifier("settings-button")
                .disabled(appState.refreshing || editMode?.wrappedValue.isEditing ?? true)
                Spacer()
                VStack {
                    if appState.refreshing {
                        ProgressView(refreshProgress)
                            .progressViewStyle(BottomBarProgressStyle(progress: refreshProgress))
                    } else if let refreshedDate = profile.minimumRefreshedDate {
                        Text("\(refreshedDate.formatted())")
                    } else {
                        #if targetEnvironment(macCatalyst)
                        Text("Press \(Image(systemName: "command")) + R to refresh").imageScale(.small)
                        #else
                        Text("Pull to refresh")
                        #endif
                    }
                }
                .foregroundColor(
                    editMode?.wrappedValue.isEditing ?? true ? .secondary : .primary
                )
                .padding(.horizontal, 8)
                .lineLimit(1)
                .font(.caption)
                Spacer()
                Button {
                    if !appState.refreshing {
                        Task {
                            await RefreshUtility.refresh(container: container, profile: profile)
                        }
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(ToolbarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityIdentifier("profile-refresh-button")
                .disabled(appState.refreshing || editMode?.wrappedValue.isEditing ?? true)
            }
        }
    }
    
    private var editButton: some View {
        EditButton()
            .buttonStyle(ToolbarButtonStyle())
            .disabled(appState.refreshing)
            .accessibilityIdentifier("edit-page-list-button")
    }
    
    private var addFeedButton: some View {
        Button {
            if case .page(let page) = selection {
                SubscriptionUtility.showSubscribe(page: page)
            } else {
                SubscriptionUtility.showSubscribe()
            }
        } label: {
            Label("Add Feed", systemImage: "plus")
        }
        .buttonStyle(ToolbarButtonStyle())
        .accessibilityIdentifier("add-feed-button")
        .disabled(appState.refreshing)
    }

    private func save() {
        do {
            try container.viewContext.save()
            DispatchQueue.main.async {
                profile.objectWillChange.send()
            }
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
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
            let page = profile.pagesArray[$0]
            for feed in page.feedsArray where feed.feedData != nil {
                container.viewContext.delete(feed.feedData!)
            }
            container.viewContext.delete(page)
        }
        
        do {
            try container.viewContext.save()
            profile.objectWillChange.send()
            // Update Inbox unread count
            NotificationCenter.default.post(name: .pagesRefreshed, object: profile.objectID)
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
