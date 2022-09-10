//
//  FeedSettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed

    @State var showingDeleteAlert: Bool = false

    var body: some View {
        Form {
            titleSection
            generalSection
            informationSection

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
                        dismiss()
                    }.accessibilityIdentifier("feed-delete-confirm-button")
                }
            )
            .modifier(FormRowModifier())
            .accessibilityIdentifier("feed-delete-button")
        }
        .onDisappear(perform: save)
        .navigationTitle("Feed Settings")
    }

    private var titleSection: some View {
        Section(header: Text("\nTitle")) {
            TextField("Title", text: $feed.wrappedTitle).modifier(TitleTextFieldModifier())
        }
    }

    private var pagePickerLabel: some View {
        Label("Page", systemImage: "square.grid.2x2")
    }

    private var pagePicker: some View {
        Picker(selection: $feed.page) {
            ForEach(feed.page?.profile?.pagesArray ?? []) { page in
                Text(page.wrappedName).tag(page as Page?)
            }
        } label: {
            pagePickerLabel
        }
        .onChange(of: feed.page) { [oldPage = feed.page] newPage in
            self.feed.userOrder = newPage?.feedsUserOrderMax ?? 0 + 1
            NotificationCenter.default.post(name: .pageRefreshed, object: oldPage?.objectID)
            NotificationCenter.default.post(name: .pageRefreshed, object: newPage?.objectID)
            dismiss()
        }
    }

    private var generalSection: some View {
        Section(header: Text("General")) {
            pagePicker.modifier(FormRowModifier())

            Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                HStack {
                    Label {
                        Text("Item Limit")
                    } icon: {
                        Image(systemName: "speedometer")
                    }
                    Spacer()
                    Text("\(feed.wrappedItemLimit)")
                }
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
            #endif

            #if targetEnvironment(macCatalyst)
            HStack {
                Label("Open Items in Browser", systemImage: "macwindow.on.rectangle")
                Spacer()
                Toggle("Open Items in Browser", isOn: $feed.browserView).labelsHidden()
            }.modifier(FormRowModifier())
            #else
            Toggle(isOn: $feed.browserView) {
                Label("Open in Browser", systemImage: "safari")
            }
            if feed.browserView {
                Toggle(isOn: $feed.readerMode) {
                    Label("Use Reader Mode", systemImage: "doc.plaintext")
                }
            }
            #endif
        }
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
                    Text("\(feed.feedData!.refreshed!.mediumShortDisplay())")
                        .foregroundColor(.secondary)
                } else {
                    Text("Never").foregroundColor(.secondary)
                }
            }.modifier(FormRowModifier())
        }
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                feed.feedData?.itemsArray.forEach { item in
                    item.objectWillChange.send()
                }
                feed.objectWillChange.send()
            } catch let error as NSError {
                CrashManager.handleCriticalError(error)
            }
        }
    }

    private func delete() {
        viewContext.delete(feed)
    }

    private func copyUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}
