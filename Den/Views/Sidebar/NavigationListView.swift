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
    
    let searchModel: SearchModel
    
    @Binding var selection: Panel?
    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress

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
            if !refreshing {
                await RefreshUtility.refresh(container: container, profile: profile)
            }
        }
        #endif
        .toolbar {
            ToolbarItem {
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
                .disabled(refreshing || editMode?.wrappedValue.isEditing ?? true)
                Spacer()
                VStack {
                    if refreshing {
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
                    if !refreshing {
                        let bgTask = UIApplication.shared.beginBackgroundTask() {
                            // Handle expiration here
                        }
                        Task {
                            await RefreshUtility.refresh(container: container, profile: profile)
                        }
                        UIApplication.shared.endBackgroundTask(bgTask)
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(ToolbarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityIdentifier("profile-refresh-button")
                .disabled(refreshing || editMode?.wrappedValue.isEditing ?? true)
            }
        }
    }

    private func save() {
        do {
            try container?.viewContext.save()
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
            container?.viewContext.delete(profile.pagesArray[$0])
        }
        save()
    }
}
