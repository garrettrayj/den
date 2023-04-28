//
//  FeedSettings.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedSettings: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed

    @State private var showingDeleteAlert: Bool = false

    var body: some View {
        if feed.managedObjectContext == nil {
            SplashNote(title: "Feed Deleted", symbol: "slash.circle")
        } else {
            Form {
                titleSection
                previewsSection
                organizeSection

                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .symbolRenderingMode(.multicolor)
                        .modifier(FormRowModifier())
                }
                .alert(
                    "Delete \(feed.wrappedTitle)?",
                    isPresented: $showingDeleteAlert,
                    actions: {
                        Button("Cancel", role: .cancel) { }
                            .accessibilityIdentifier("feed-delete-cancel-button")
                        Button("Delete", role: .destructive) {
                            deleteFeed()
                        }.accessibilityIdentifier("feed-delete-confirm-button")
                    }
                )
                .modifier(ListRowModifier())
                .accessibilityIdentifier("feed-delete-button")
            }
            .background(GroupedBackground())
            .onDisappear(perform: save)
            .navigationTitle("Feed Settings")
        }
    }

    private var titleSection: some View {
        Section(header: Text("Title").modifier(FirstFormHeaderModifier())) {
            TextField("Title", text: $feed.wrappedTitle)
                .modifier(FormRowModifier())
                .modifier(TitleTextFieldModifier())
        }
        .modifier(ListRowModifier())
    }

    private var previewsSection: some View {
        Section {
            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Customize").modifier(FormRowModifier())
                Spacer()
                Toggle("Customize", isOn: $feed.customPreviews).labelsHidden()
            }
            #else
            Toggle(isOn: $feed.customizeSettings) {
                Text("Customize").modifier(FormRowModifier())
            }
            #endif

            if feed.customPreviews {
                PreviewSettings(
                    itemLimit: $feed.wrappedItemLimit,
                    previewStyle: $feed.wrappedPreviewStyle,
                    hideImages: $feed.hideImages,
                    hideTeasers: $feed.hideTeasers,
                    browserView: $feed.browserView,
                    readerMode: $feed.readerMode
                )
            }

        } header: {
            Text("Previews")
        }
    }

    private var organizeSection: some View {
        Section {
            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Page").modifier(FormRowModifier())
                Spacer()
                pagePicker.labelsHidden().scaledToFit()
            }
            #else
            pagePicker
            #endif
        } header: {
            Text("Move")
        }
        .modifier(ListRowModifier())
    }

    private var pagePicker: some View {
        Picker(selection: $feed.page) {
            ForEach(feed.page?.profile?.pagesArray ?? []) { page in
                Text(page.wrappedName).tag(page as Page?)
            }
        } label: {
            Text("Page").modifier(FormRowModifier())
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
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                feed.feedData?.itemsArray.forEach { item in
                    item.objectWillChange.send()
                }
                feed.objectWillChange.send()
                feed.page?.profile?.objectWillChange.send()
            } catch let error as NSError {
                CrashUtility.handleCriticalError(error)
            }
        }
    }

    private func deleteFeed() {
        if let feedData = feed.feedData {
            viewContext.delete(feedData)
        }
        viewContext.delete(feed)

        do {
            try viewContext.save()
            feed.page?.profile?.objectWillChange.send()
            dismiss()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
