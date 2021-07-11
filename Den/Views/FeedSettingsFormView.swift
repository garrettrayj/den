//
//  FeedOptionsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedSettingsFormView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var profileManager: ProfileManager

    @ObservedObject var feed: Feed

    @State private var pickedPage: Int = 0

    private var onDelete: () -> Void
    private var onMove: () -> Void

    var body: some View {
        let pagePickerSelection = Binding<Int>(
            get: {
                return self.pickedPage
            },
            set: {
                guard let pages = feed.page?.profile?.pagesArray else { return }
                self.pickedPage = $0
                self.feed.userOrder = pages[$0].feedsUserOrderMax + 1
                self.feed.page = pages[$0]
                self.onMove()
            }
        )

        return Form {
            Section {
                HStack {
                    Text("Title")
                    TextField("Title", text: $feed.wrappedTitle).multilineTextAlignment(.trailing)
                }

                Picker("Page", selection: pagePickerSelection) {
                    ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                        Text(page.wrappedName).tag(
                            profileManager.activeProfile?.pagesArray.firstIndex(of: page)
                        )
                    }
                }
                .onAppear {
                    if
                        let page = self.feed.page,
                        let pageIndex = page.profile?.pagesArray.firstIndex(of: page)
                    {
                        self.pickedPage = pageIndex
                    }
                }

                HStack {
                    Toggle(isOn: $feed.showThumbnails) {
                        Text("Show Thumbnails")
                    }
                }

                #if !targetEnvironment(macCatalyst)
                HStack {
                    Toggle(isOn: $feed.readerMode) {
                        Text("Enter Reader Mode if Available")
                    }
                }
                #endif
            }

            Section {
                HStack(alignment: .center) {
                    Text("URL")
                    Spacer()
                    Text(feed.urlString).lineLimit(1).foregroundColor(.secondary)
                    Button(action: copyFeedUrl) {
                        Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(width: 16, height: 16)
                    }
                }

                HStack(alignment: .center) {
                    Text("Last Refresh")
                    Spacer()
                    if feed.feedData?.refreshed != nil {
                        Text("\(feed.feedData!.refreshed!, formatter: DateFormatter.mediumShort)")
                            .foregroundColor(.secondary)
                    } else {
                        Text("Never").foregroundColor(.secondary)
                    }
                }

            }
            Section {
                Button(action: deleteFeed) {
                    Label("Delete Feed", systemImage: "trash").foregroundColor(Color.red)
                }
            }
        }
        .onDisappear(perform: saveFeed)
    }

    init(
        feed: Feed,
        onDelete: @escaping () -> Void,
        onMove: @escaping () -> Void
    ) {
        self.feed = feed
        self.onDelete = onDelete
        self.onMove = onMove
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
        self.viewContext.delete(self.feed)
        self.onDelete()
    }

    private func copyFeedUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}
