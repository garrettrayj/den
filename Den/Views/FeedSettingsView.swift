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
    @EnvironmentObject var profileManager: ProfileManager

    @Binding var activeFeed: String?

    @ObservedObject var viewModel: FeedSettingsViewModel

    var body: some View {
        Form {
            title
            settings
            info
            actions
        }
        .onDisappear(perform: viewModel.save)
        .navigationTitle("Feed Settings")
    }

    private var title: some View {
        Section(header: Text("Title").modifier(SectionHeaderModifier())) {
            HStack {
                TextField("Title", text: $viewModel.feed.wrappedTitle)
                    .lineLimit(1)
                    .padding(.vertical, 4)
            }
        }
    }

    private var settings: some View {
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

                viewModel.feed.userOrder = page.feedsUserOrderMax + 1
                viewModel.feed.page = page
            }
        )

        return Section(header: Text("Settings").modifier(SectionHeaderModifier())) {
            #if targetEnvironment(macCatalyst)
            HStack {
                Label("Page", systemImage: "square.grid.2x2").padding(.vertical, 4)
                Spacer()
                Picker("", selection: pagePickerSelection) {
                    ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                        Text(page.wrappedName).tag(page.id?.uuidString)
                    }
                }
                .frame(maxWidth: 200)
            }
            HStack {
                Label("Show Thumbnails", systemImage: "photo").padding(.vertical, 4)
                Spacer()
                Toggle("Show Thumbnails", isOn: $viewModel.feed.showThumbnails).labelsHidden()
            }
            #else
            Picker(
                selection: pagePickerSelection,
                label: Label("Page", systemImage: "square.grid.2x2"),
                content: {
                    ForEach(contentViewModel.activeProfile?.pagesArray ?? []) { page in
                        Text(page.wrappedName).tag(page.id?.uuidString)
                    }
                }
            )
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
                Label("URL", systemImage: "globe")
                Spacer()
                Text(viewModel.feed.urlString).lineLimit(1).foregroundColor(.secondary).padding(.vertical, 4)
                Button(action: viewModel.copyUrl) {
                    Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(width: 16, height: 16)
                }
            }

            HStack {
                Label("Refreshed", systemImage: "arrow.clockwise").padding(.vertical, 4)
                Spacer()
                if viewModel.feed.feedData?.refreshed != nil {
                    Text("\(viewModel.feed.feedData!.refreshed!, formatter: DateFormatter.mediumShort)")
                        .foregroundColor(.secondary)
                } else {
                    Text("Never").foregroundColor(.secondary)
                }
            }
        }
    }

    private var actions: some View {
        Section(header: Text("Actions").modifier(SectionHeaderModifier())) {
            Button(action: viewModel.openWebsite) {
                Label("Open Website", systemImage: "arrow.up.right.square")
            }
            .padding(.vertical, 4)
            .disabled(viewModel.feed.feedData?.link == nil)

            Button { viewModel.showingDeleteAlert = true } label: {
                Label("Delete Feed", systemImage: "trash").foregroundColor(.red)
            }
            .padding(.vertical, 4)
            .alert(isPresented: $viewModel.showingDeleteAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("Removing a subscription cannot be undone"),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.delete()
                        activeFeed = nil
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
