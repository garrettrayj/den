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
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var viewModel: FeedViewModel

    @State private var showingDeleteAlert = false

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
                "Delete \(viewModel.feed.wrappedTitle)?",
                isPresented: $showingDeleteAlert,
                actions: {
                    Button("Cancel", role: .cancel) { }
                        .accessibilityIdentifier("feed-delete-cancel-button")
                    Button("Delete", role: .destructive) {
                        viewModel.delete()
                    }.accessibilityIdentifier("feed-delete-confirm-button")
                }
            )
            .modifier(FormRowModifier())
            .accessibilityIdentifier("feed-delete-button")
        }
        .onDisappear(perform: viewModel.save)
        .navigationTitle("Feed Settings")
    }

    private var titleSection: some View {
        Section(header: Text("Title")) {
            TextField("Title", text: $viewModel.feed.wrappedTitle).modifier(TitleTextFieldModifier())
        }.modifier(SectionHeaderModifier())
    }

    private var pagePicker: some View {
        let pagePickerSelection = Binding<String?>(
            get: {
                return viewModel.feed.page?.id?.uuidString
            },
            set: {
                guard
                    let pageIdString = $0,
                    let page = profileManager.activeProfile?.pagesArray.first(where: { page in
                        return page.id?.uuidString == pageIdString
                    })
                else { return }

                NotificationCenter.default.post(
                    name: .pageRefreshed,
                    object: viewModel.feed.page?.objectID
                )

                viewModel.feed.userOrder = page.feedsUserOrderMax + 1
                viewModel.feed.page = page

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

            Stepper(value: $viewModel.feed.wrappedItemLimit, in: 1...100, step: 1) {
                Label(
                    "Item Limit: \(viewModel.feed.wrappedItemLimit)",
                    systemImage: "list.bullet.rectangle"
                )
            }.modifier(FormRowModifier())

            #if targetEnvironment(macCatalyst)
            HStack {
                Label("Show Thumbnails", systemImage: "photo")
                Spacer()
                Toggle("Show Thumbnails", isOn: $viewModel.feed.showThumbnails).labelsHidden()
            }.modifier(FormRowModifier())
            #else
            Toggle(isOn: $viewModel.feed.showThumbnails) {
                Label("Show Thumbnails", systemImage: "photo")
            }
            Toggle(isOn: $viewModel.feed.readerMode) {
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
                Text(viewModel.feed.urlString).lineLimit(1).foregroundColor(.secondary)
                Button(action: viewModel.copyUrl) {
                    Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(width: 16, height: 16)
                }.accessibilityIdentifier("feed-copy-url-button")
            }.modifier(FormRowModifier())

            HStack {
                Label("Refreshed", systemImage: "arrow.clockwise")
                Spacer()
                if viewModel.feed.feedData?.refreshed != nil {
                    Text("\(viewModel.feed.feedData!.refreshed!, formatter: DateFormatter.mediumShort)")
                        .foregroundColor(.secondary)
                } else {
                    Text("Never").foregroundColor(.secondary)
                }
            }.modifier(FormRowModifier())
        }.modifier(SectionHeaderModifier())
    }
}
