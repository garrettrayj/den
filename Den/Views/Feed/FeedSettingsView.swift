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
    @EnvironmentObject private var haptics: Haptics

    @ObservedObject var feed: Feed

    @State private var showingDeleteAlert: Bool = false

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
        Section(header: Text("Title").modifier(FormFirstHeaderModifier())) {
            TextField("Title", text: $feed.wrappedTitle).modifier(TitleTextFieldModifier())
        }
    }

    private var pagePickerLabel: some View {
        Text("Page")
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
            pagePicker
                .modifier(FormRowModifier())

            Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                Text("Item Limit: \(feed.wrappedItemLimit)")
            }
            .onChange(of: feed.itemLimit, perform: { _ in
                haptics.lightImpactFeedbackGenerator.impactOccurred()
            })
            .modifier(FormRowModifier())

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Show Thumbnails")
                Spacer()
                Toggle("Show Thumbnails", isOn: $feed.showThumbnails).labelsHidden()
            }.modifier(FormRowModifier())
            #else
            Toggle(isOn: $feed.showThumbnails) {
                Text("Show Thumbnails")
            }
            #endif

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Open Items in Browser")
                Spacer()
                Toggle("Open Items in Browser", isOn: $feed.browserView).labelsHidden()
            }.modifier(FormRowModifier())
            #else
            Toggle(isOn: $feed.browserView) {
                Text("Open Items in Browser")
            }
            if feed.browserView {
                Toggle(isOn: $feed.readerMode) {
                    Text("Use Reader Mode")
                }
            }
            #endif
        }
    }

    private var informationSection: some View {
        Section(header: Text("Information")) {
            Button(action: copyUrl) {
                HStack {
                    Text("Feed URL").foregroundColor(.primary)
                    Spacer()
                    Text(feed.urlString).lineLimit(1).foregroundColor(.secondary)
                    Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(width: 16, height: 16)
                }
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("feed-copy-url-button")
            .modifier(FormRowModifier())

            HStack {
                Text("Refreshed")
                Spacer()
                if let refreshed = feed.feedData?.refreshed {
                    Text("\(refreshed.formatted(date: .abbreviated, time: .shortened))")
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
        feed.page?.profile?.objectWillChange.send()
    }

    private func copyUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}
