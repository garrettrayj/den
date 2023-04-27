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
            Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                Text("Limit: \(feed.wrappedItemLimit)").modifier(FormRowModifier())
            }
            .onChange(of: feed.itemLimit, perform: { _ in
                Haptics.lightImpactFeedbackGenerator.impactOccurred()
            })

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Preferred Style").modifier(FormRowModifier())
                Spacer()
                previewStylePicker.labelsHidden().scaledToFit()
            }
            #else
            previewStylePicker
            #endif

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Show Thumbnails").modifier(FormRowModifier())
                Spacer()
                Toggle("Show Thumbnails", isOn: $feed.showThumbnails).labelsHidden()
            }
            #else
            Toggle(isOn: $feed.showThumbnails) {
                Text("Show Thumbnails").modifier(FormRowModifier())
            }
            #endif

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Open in Browser").modifier(FormRowModifier())
                Spacer()
                Toggle("Open in Browser", isOn: $feed.browserView).labelsHidden()
            }
            #else
            Toggle(isOn: $feed.browserView) {
                Text("Open in Browser").modifier(FormRowModifier())
            }
            if feed.browserView {
                Toggle(isOn: $feed.readerMode) {
                    Text("Use Reader Mode").modifier(FormRowModifier())
                }
            }
            #endif
        } header: {
            Text("Previews")
        }
        .modifier(ListRowModifier())
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

    private var previewStylePicker: some View {
        Picker(selection: $feed.wrappedPreviewStyle) {
            Text("Compressed").tag(PreviewStyle.compressed)
            Text("Expanded").tag(PreviewStyle.expanded)
        } label: {
            Text("Preferred Style").modifier(FormRowModifier())
        }
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
