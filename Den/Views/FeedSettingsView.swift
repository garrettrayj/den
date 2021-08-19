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
    @EnvironmentObject var refreshManager: RefreshManager
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

    private func close() {
        presentationMode.wrappedValue.dismiss()
    }

    var form: some View {
        return Form {
            title
            settings
            info
            actions
        }
        .onDisappear(perform: saveFeed)
        .navigationTitle("Feed Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button(action: close) {
                    Label("Close", systemImage: "xmark.circle")
                }.buttonStyle(ActionButtonStyle())
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
        let pagePickerSelection = Binding<Page?>(
            get: {
                return feed.page
            },
            set: {
                guard let page = $0 else { return }
                feed.userOrder = page.feedsUserOrderMax + 1
                feed.page = page
                close()
            }
        )

        return Section(header: Text("Settings")) {

            HStack {
                Text("Page").padding(.vertical, 4)
                Spacer()
                Picker("", selection: pagePickerSelection) {
                    ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                        Text(page.wrappedName).tag(page as Page?)
                    }
                }
                .frame(maxWidth: 200)
            }

            HStack {
                Text("Show Images")
                Spacer()
                Toggle("", isOn: $feed.showThumbnails).padding(.vertical, 4)
            }

            #if !targetEnvironment(macCatalyst)
            HStack {
                Toggle(isOn: $feed.readerMode) {
                    Text("Enter Reader Mode if Available")
                }
            }
            #endif
        }
    }

    private var info: some View {
        Section(header: Text("Info")) {
            HStack(alignment: .center) {
                Text("URL").padding(.vertical, 4)
                Spacer()
                Text(feed.urlString).lineLimit(1).foregroundColor(.secondary)
                Button(action: copyFeedUrl) {
                    Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(width: 16, height: 16)
                }.buttonStyle(ActionButtonStyle())
            }

            HStack(alignment: .center) {
                Text("Refreshed").padding(.vertical, 4)
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
            .buttonStyle(ActionButtonStyle())
            .disabled(feed.feedData?.link == nil)

            Button { showingDeleteAlert = true } label: {
                Label("Delete Feed", systemImage: "trash")
            }
            .padding(.vertical, 4)
            .buttonStyle(DestructiveButtonStyle())
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("\(feed.wrappedTitle)\nwill be permanently removed."),
                    primaryButton: .destructive(Text("Delete")) {
                        self.deleteFeed()
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

    private func saveFeed() {
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }

            if let feedData = feed.feedData {
                feedData.itemsArray.forEach { item in
                    item.objectWillChange.send()
                }
            }
        }
    }

    private func deleteFeed() {
        viewContext.delete(self.feed)
        close()
    }

    private func copyFeedUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}
