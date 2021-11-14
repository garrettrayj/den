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

    let feedDeleted = NotificationCenter.default.publisher(for: .feedDeleted)

    var body: some View {
        Form {
            titleSection
            configurationSection
            info
            Spacer().listRowBackground(Color.clear)
        }
        .onDisappear(perform: save)
        .navigationTitle("Feed Settings")
        .onReceive(feedDeleted) { _ in
            dismiss()
        }
        .toolbar { toolbar }
    }

    private var titleSection: some View {
        Section(header: Text("Title").modifier(SectionHeaderModifier())) {
            TextField("Title", text: $feed.wrappedTitle).lineLimit(1).modifier(FormRowModifier())
        }
    }

    private var configurationSection: some View {
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

        return Section(header: Text("Settings").modifier(SectionHeaderModifier())) {
            #if targetEnvironment(macCatalyst)
            HStack {
                Label("Page", systemImage: "square.grid.2x2")
                Spacer()
                Picker("", selection: pagePickerSelection) {
                    ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                        Text(page.wrappedName).tag(page.id?.uuidString)
                    }
                }
                .frame(maxWidth: 200)
            }.modifier(FormRowModifier())
            HStack {
                Label("Show Thumbnails", systemImage: "photo")
                Spacer()
                Toggle("Show Thumbnails", isOn: $feed.showThumbnails).labelsHidden()
            }.modifier(FormRowModifier())
            #else
            Picker(
                selection: pagePickerSelection,
                label: Label("Page", systemImage: "square.grid.2x2"),
                content: {
                    ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
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
                Label {
                    Text("RSS URL").lineLimit(1)
                } icon: {
                    Image(uiImage: UIImage(named: "RSSIcon")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14, alignment: .center)
                }
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
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash").symbolRenderingMode(.multicolor)
                }
                .alert("Remove \(feed.wrappedTitle)?", isPresented: $showingDeleteAlert, actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        delete()
                    }
                })
            }.buttonStyle(ToolbarButtonStyle())
        }
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    private func delete() {
        viewContext.delete(feed)
        // Save handled by onDissapear(), which will be triggered by...
        NotificationCenter.default.post(name: .feedDeleted, object: nil)
    }

    private func copyUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}
