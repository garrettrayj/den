//
//  FeedSettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedSettingsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var profileManager: ProfileManager

    @ObservedObject var feed: Feed

    @State var showingDeleteAlert = false

    var body: some View {
        Form {
            titlePageSection
            limitsSection
            configurationSection
            info
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
                        Button("Delete", role: .destructive) {
                            delete()
                        }
                    }
                )
            }
        }
    }

    private var titlePageSection: some View {
        Section(header: Text("Title & Page")) {

            #if targetEnvironment(macCatalyst)
            HStack {
                TextField("Title", text: $feed.wrappedTitle).modifier(TitleTextFieldModifier())
                Spacer()
                pagePicker.frame(maxWidth: 160).labelsHidden()
            }.modifier(FormRowModifier())
            #else
            TextField("Title", text: $feed.wrappedTitle).modifier(TitleTextFieldModifier())
            pagePicker
            #endif
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

                feed.userOrder = page.feedsUserOrderMax + 1
                feed.page = page
            }
        )

        return Picker(selection: pagePickerSelection) {
            ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                Text(page.wrappedName).tag(page.id?.uuidString)
            }
        } label: {
            Label("Page", systemImage: "square.grid.2x2")
        }
    }

    private var limitsSection: some View {
        Section(header: Text("Limits")) {
            Stepper(value: $feed.wrappedPreviewLimit, in: 1...100, step: 1) {
                Label(
                    "Preview Items: \(feed.wrappedPreviewLimit)",
                    systemImage: "text.below.photo"
                )
            }.modifier(FormRowModifier())

            Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                Label(
                    "Total Items: \(feed.wrappedItemLimit)",
                    systemImage: "list.bullet.rectangle"
                )
            }.modifier(FormRowModifier())
        }.modifier(SectionHeaderModifier())
    }

    private var configurationSection: some View {
        Section(header: Text("Images")) {
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

    private var info: some View {
        Section(header: Text("Info")) {
            HStack {
                Label("RSS URL", systemImage: "dot.radiowaves.up.forward").lineLimit(1)
                Spacer()
                Text(feed.urlString).lineLimit(1).foregroundColor(.secondary)
                Button(action: copyUrl) {
                    Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(width: 16, height: 16)
                }
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
