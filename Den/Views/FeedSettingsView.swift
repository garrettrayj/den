//
//  FeedWidgetSettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var profileManager: ProfileManager

    @ObservedObject var feed: Feed

    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            form
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var form: some View {
        return Form {
            title
            settings
            info
            actions
        }
        .onDisappear(perform: save)
        .navigationTitle("Feed Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    Label("Close", systemImage: "xmark.circle")
                }.buttonStyle(ToolbarButtonStyle())
            }
        }
    }

    private var title: some View {
        Section(header: Text("Title")) {
            HStack {
                TextField("Title", text: $feed.wrappedTitle)
                    .lineLimit(1)
                    .padding(.vertical, 4)
            }
        }
    }

    private var settings: some View {
        let pagePickerSelection = Binding<String?>(
            get: {
                return feed.page?.id?.uuidString
            },
            set: {
                guard
                    let pageIdString = $0,
                    let page = profileManager.activeProfile.pagesArray.first(where: { page in
                        return page.id?.uuidString == pageIdString
                    })
                else { return }

                feed.userOrder = page.feedsUserOrderMax + 1
                feed.page = page
                presentationMode.wrappedValue.dismiss()
            }
        )

        return Section(header: Text("Settings")) {
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
                Toggle("Show Thumbnails", isOn: $feed.showThumbnails).labelsHidden()
            }
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
        Section(header: Text("Info")) {
            HStack {
                Label("URL", systemImage: "globe")
                Spacer()
                Text(feed.urlString).lineLimit(1).foregroundColor(.secondary).padding(.vertical, 4)
                Button(action: copyUrl) {
                    Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(width: 16, height: 16)
                }
            }

            HStack {
                Label("Refreshed", systemImage: "arrow.clockwise").padding(.vertical, 4)
                Spacer()
                if feed.feedData?.refreshed != nil {
                    Text("\(feed.feedData!.refreshed!, formatter: DateFormatter.mediumShort)")
                        .foregroundColor(.secondary)
                } else {
                    Text("Never").foregroundColor(.secondary)
                }
            }
        }
    }

    private var actions: some View {
        Section(header: Text("Actions")) {
            Button(action: openWebsite) {
                Label("Open Website", systemImage: "arrow.up.right.square")
            }
            .padding(.vertical, 4)
            .disabled(feed.feedData?.link == nil)

            Button { showingDeleteAlert = true } label: {
                Label("Delete Feed", systemImage: "trash").foregroundColor(.red)
            }
            .padding(.vertical, 4)
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("Removing a subscription cannot be undone"),
                    primaryButton: .destructive(Text("Delete")) {
                        self.delete()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func openWebsite() {
        if let url = feed.feedData?.link {
            UIApplication.shared.open(url)
        }
    }

    private func save() {
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    private func delete() {
        viewContext.delete(self.feed)
        presentationMode.wrappedValue.dismiss()
    }

    private func copyUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}
