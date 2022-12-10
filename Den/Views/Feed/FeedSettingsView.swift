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

    @State private var showingDeleteAlert: Bool = false

    var body: some View {
        Form {
            titleSection
            previewsSection
            infoSection
            organizeSection
        }
        .onDisappear(perform: save)
        .navigationTitle("Feed Settings")
    }

    private var titleSection: some View {
        Section(header: Text("Title").modifier(FormFirstHeaderModifier())) {
            TextField("Title", text: $feed.wrappedTitle).modifier(TitleTextFieldModifier())
        }
    }

    private var previewsSection: some View {
        Section {
            Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                Text("Limit: \(feed.wrappedItemLimit)")
            }
            .onChange(of: feed.itemLimit, perform: { _ in
                Haptics.lightImpactFeedbackGenerator.impactOccurred()
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
                Text("Open in Browser")
                Spacer()
                Toggle("Open in Browser", isOn: $feed.browserView).labelsHidden()
            }.modifier(FormRowModifier())
            #else
            Toggle(isOn: $feed.browserView) {
                Text("Open in Browser")
            }
            if feed.browserView {
                Toggle(isOn: $feed.readerMode) {
                    Text("Use Reader Mode")
                }
            }
            #endif
        } header: {
            Text("Previews")
        }
    }

    private var infoSection: some View {
        Section(header: Text("Info")) {
            Button {
                let pasteboard = UIPasteboard.general
                pasteboard.string = feed.url!.absoluteString
            } label: {
                HStack {
                    Text("URL").foregroundColor(.primary)
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

    private var organizeSection: some View {
        Section {
            Picker(selection: $feed.page) {
                ForEach(feed.page?.profile?.pagesArray ?? []) { page in
                    Text(page.wrappedName).tag(page as Page?)
                }
            } label: {
                Text("Move")
            }
            .onChange(of: feed.page) { [oldPage = feed.page] newPage in
                self.feed.userOrder = newPage?.feedsUserOrderMax ?? 0 + 1
                NotificationCenter.default.post(
                    name: .feedRefreshed,
                    object: self.feed.objectID,
                    userInfo: ["pageObjectID": oldPage?.objectID as Any]
                )
                NotificationCenter.default.post(
                    name: .feedRefreshed,
                    object: self.feed.objectID,
                    userInfo: ["pageObjectID": newPage?.objectID as Any]
                )
                dismiss()
            }
            .modifier(FormRowModifier())

            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Text("Delete")
            }
            .alert(
                "Delete \(feed.wrappedTitle)?",
                isPresented: $showingDeleteAlert,
                actions: {
                    Button("Cancel", role: .cancel) { }
                        .accessibilityIdentifier("feed-delete-cancel-button")
                    Button("Delete", role: .destructive) {
                        if let feedData = feed.feedData {
                            viewContext.delete(feedData)
                        }
                        viewContext.delete(feed)
                        feed.page?.profile?.objectWillChange.send()
                        dismiss()
                    }.accessibilityIdentifier("feed-delete-confirm-button")
                }
            )
            .modifier(FormRowModifier())
            .accessibilityIdentifier("feed-delete-button")
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
                CrashUtility.handleCriticalError(error)
            }
        }
    }
}
