//
//  FeedWidgetSettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedSettingsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var profileManager: ProfileManager

    @ObservedObject var feed: Feed

    @State var showingDeleteAlert = false

    var body: some View {
        Form {
            titleSection
            limitsSection
            configurationSection
            info
            Spacer().listRowBackground(Color.clear)
        }
        .onDisappear(perform: save)
        .navigationTitle("Feed Settings")
        .onReceive(
            NotificationCenter.default.publisher(for: .feedWillBeDeleted, object: feed.objectID)
        ) { _ in
            dismiss()
        }
        .toolbar {
            ToolbarItem {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash").symbolRenderingMode(.multicolor)
                }
                .buttonStyle(NavigationBarButtonStyle())
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

    private var titleSection: some View {
        Section(header: Text("Title and Page").modifier(SectionHeaderModifier())) {
            TextField("Title", text: $feed.wrappedTitle)
                .modifier(TitleTextFieldModifier())
                .modifier(FormRowModifier())

            pagePicker
        }
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

        #if targetEnvironment(macCatalyst)
        return HStack {
            Label("Page", systemImage: "square.grid.2x2")
            Spacer()
            Picker("", selection: pagePickerSelection) {
                ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                    Text(page.wrappedName).tag(page.id?.uuidString)
                }
            }
            .frame(maxWidth: 200)
        }.modifier(FormRowModifier())
        #else
        return Picker(
            selection: pagePickerSelection,
            label: Label("Page", systemImage: "square.grid.2x2"),
            content: {
                ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                    Text(page.wrappedName).tag(page.id?.uuidString)
                }
            }
        )
        #endif
    }

    private var limitsSection: some View {
        Section(header: Text("Limits").modifier(SectionHeaderModifier())) {
            Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                Label(
                    "Total Items: \(feed.wrappedItemLimit)",
                    systemImage: "list.bullet.rectangle"
                )
            }.modifier(FormRowModifier())

            Stepper(value: $feed.wrappedPreviewLimit, in: 1...100, step: 1) {
                Label(
                    "Previews with Images: \(feed.wrappedPreviewLimit)",
                    systemImage: "text.below.photo"
                )
            }.modifier(FormRowModifier())
        }
    }

    private var configurationSection: some View {
        Section(header: Text("Images").modifier(SectionHeaderModifier())) {
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
        }
    }

    private var info: some View {
        Section(header: Text("Info").modifier(SectionHeaderModifier())) {
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
        }
    }

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup {
            HStack(spacing: 0) {

            }.buttonStyle(NavigationBarButtonStyle())
        }
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                feed.feedData?.itemsArray.forEach { item in
                    item.objectWillChange.send()
                }
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    private func delete() {
        NotificationCenter.default.post(name: .feedWillBeDeleted, object: feed.objectID)

        viewContext.delete(feed)
        save()
    }

    private func copyUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}
