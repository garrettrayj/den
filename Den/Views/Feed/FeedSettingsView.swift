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

    @ObservedObject var viewModel: FeedSettingsViewModel

    var body: some View {
        Form {
            titleSection
            generalSection
            informationSection

            Button(role: .destructive) {
                viewModel.showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash").symbolRenderingMode(.multicolor)
            }
            .alert(
                "Delete \(viewModel.feed.wrappedTitle)?",
                isPresented: $viewModel.showingDeleteAlert,
                actions: {
                    Button("Cancel", role: .cancel) { }
                        .accessibilityIdentifier("feed-delete-cancel-button")
                    Button("Delete", role: .destructive) {
                        viewModel.delete()
                        dismiss()
                    }.accessibilityIdentifier("feed-delete-confirm-button")
                }
            )
            .modifier(FormRowModifier())
            .accessibilityIdentifier("feed-delete-button")
        }
        .onDisappear(perform: viewModel.save)
        .navigationTitle("Feed Settings")
        .modifier(BackNavigationModifier(title: viewModel.feed.wrappedTitle))
    }

    private var titleSection: some View {
        Section(header: Text("Title")) {
            TextField("Title", text: $viewModel.feed.wrappedTitle).modifier(TitleTextFieldModifier())
        }.modifier(SectionHeaderModifier())
    }

    private var pagePickerLabel: some View {
        Label("Page", systemImage: "square.grid.2x2")
    }

    private var pagePicker: some View {
        Picker(selection: viewModel.pageSelection) {
            ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                Text(page.wrappedName).tag(page as Page?)
            }
        } label: {
            pagePickerLabel
        }
        .onChange(of: viewModel.feed.page) { _ in
            dismiss()
        }
    }

    private var generalSection: some View {
        Section(header: Text("General")) {
            #if targetEnvironment(macCatalyst)
            HStack {
                pagePickerLabel
                Spacer()
                pagePicker.frame(width: 200)
            }.modifier(FormRowModifier())
            #else
            pagePicker.modifier(FormRowModifier())
            #endif

            Stepper(value: $viewModel.feed.wrappedItemLimit, in: 1...100, step: 1) {
                HStack {
                    Label {
                        Text("Item Limit")
                    } icon: {
                        Image(systemName: "speedometer")
                    }
                    Spacer()
                    Text("\(viewModel.feed.wrappedItemLimit)")
                }
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
                    Text("\(viewModel.feed.feedData!.refreshed!.mediumShortDisplay())")
                        .foregroundColor(.secondary)
                } else {
                    Text("Never").foregroundColor(.secondary)
                }
            }.modifier(FormRowModifier())
        }.modifier(SectionHeaderModifier())
    }
}
