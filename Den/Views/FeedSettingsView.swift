//
//  FeedSettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var feed: Feed

    @State private var showingDeleteAlert = false

    var body: some View {
        Form {
            titleSection
            generalSection
            informationSection
        }
        .onDisappear(perform: save)
        .navigationTitle("Feed Settings")
        .toolbar {
            ToolbarItem {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash").symbolRenderingMode(.multicolor)
                }
                .alert(
                    "Delete \(feed.wrappedTitle)?",
                    isPresented: $showingDeleteAlert,
                    actions: {
                        Button("Cancel", role: .cancel) { }
                            .accessibilityIdentifier("feed-delete-cancel-button")
                        Button("Delete", role: .destructive) {
                            delete()
                        }.accessibilityIdentifier("feed-delete-confirm-button")
                    }
                )
                .accessibilityIdentifier("feed-delete-button")
            }
        }
    }

    private var titleSection: some View {
        Section(header: Text("Title")) {
            TextField("Title", text: $feed.wrappedTitle).modifier(TitleTextFieldModifier())
        }.modifier(SectionHeaderModifier())
    }

    private var pagePicker: some View {
        let pagePickerSelection = Binding<String?>(
            get: {
                return feed.page?.id?.uuidString
            },
            set: {
                guard
                    let pageIdString = $0,
                    let page = profileManager.activeProfile?.pagesArray.first(where: { page in
                        return page.id?.uuidString == pageIdString
                    })
                else { return }

                NotificationCenter.default.post(name: .pageRefreshed, object: feed.page?.objectID)

                feed.userOrder = page.feedsUserOrderMax + 1
                feed.page = page

                dismiss()
            }
        )

        return Picker(selection: pagePickerSelection) {
            ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                Text(page.wrappedName).tag(page.id?.uuidString)
            }
        } label: {
            HStack {
                Label("Page", systemImage: "square.grid.2x2")
                Spacer()
            }
        }
    }

    private var generalSection: some View {
        Section(header: Text("General")) {
            pagePicker.modifier(FormRowModifier())

            Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                Label(
                    "Item Limit: \(feed.wrappedItemLimit)",
                    systemImage: "list.bullet.rectangle"
                )
            }.modifier(FormRowModifier())

            #if targetEnvironment(macCatalyst)
            HStack {
                Label("Show Thumbnails", systemImage: "photo")
                Spacer()
                Toggle("Show Thumbnails", isOn: $feed.showThumbnails).labelsHidden()
            }.modifier(FormRowModifier())
            #else
            Toggle(isOn: $feed.showThumbnails) {
                Label("Show Thumbnails", systemImage: "photo")
            }
            Toggle(isOn: $feed.readerMode) {
                Label("Use Reader Mode", systemImage: "doc.plaintext")
            }
            #endif
        }.modifier(SectionHeaderModifier())
    }

    private var informationSection: some View {
        Section(header: Text("Information")) {
            HStack {
                Label("Feed URL", systemImage: "link").lineLimit(1)
                Spacer()
                Text(feed.urlString).lineLimit(1).foregroundColor(.secondary)
                Button(action: copyUrl) {
                    Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(width: 16, height: 16)
                }.accessibilityIdentifier("feed-copy-url-button")
            }.modifier(FormRowModifier())

            HStack {
                Label("Refreshed", systemImage: "arrow.clockwise")
                Spacer()
                if feed.feedData?.refreshed != nil {
                    Text("\(feed.feedData!.refreshed!, formatter: DateFormatter.mediumShort)")
                        .foregroundColor(.secondary)
                } else {
                    Text("Never").foregroundColor(.secondary)
                }
            }.modifier(FormRowModifier())
        }.modifier(SectionHeaderModifier())
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                feed.feedData?.itemsArray.forEach { item in
                    item.objectWillChange.send()
                }
                NotificationCenter.default.post(name: .feedRefreshed, object: feed.objectID)
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    private func delete() {
        guard let pageObjectID = feed.page?.objectID else { return }

        viewContext.delete(feed)
        save()

        NotificationCenter.default.post(name: .pageRefreshed, object: pageObjectID)
    }

    private func copyUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}
