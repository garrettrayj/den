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
    @ObservedObject var feed: Feed
    @State private var pickedPage: Int = 0

    var onDelete: () -> Void
    var onMove: () -> Void
    
    var pages: FetchedResults<Page>
    
    var body: some View {
        let pagePickerSelection = Binding<Int>(
            get: {
                return self.pickedPage
            },
            set: {
                self.pickedPage = $0
                self.feed.userOrder = self.pages[$0].feedsUserOrderMax + 1
                self.feed.page = self.pages[$0]
                self.onMove()
            }
        )
        
        return Form {
            Section() {
                HStack {
                    Text("Title")
                    TextField("Title", text: $feed.wrappedTitle).multilineTextAlignment(.trailing)
                }
                
                Picker("Page", selection: pagePickerSelection) {
                    ForEach(0 ..< pages.count) {
                        Text(self.pages[$0].wrappedName).tag($0)
                    }
                }
                .onAppear {
                    if let page = self.feed.page, let pageIndex = self.pages.firstIndex(of: page) {
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
            
            Section() {
                HStack(alignment: .center) {
                    Text("URL")
                    Spacer()
                    Text(feed.urlString).lineLimit(1).foregroundColor(.secondary)
                    Button(action: copyFeed) {
                        Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(width: 16, height: 16)
                    }
                }
                
                HStack(alignment: .center) {
                    Text("Last Refresh")
                    Spacer()
                    if feed.feedData?.refreshed != nil {
                        Text("\(feed.feedData!.refreshed!, formatter: DateFormatter.create())").foregroundColor(.secondary)
                    } else {
                        Text("Never").foregroundColor(.secondary)
                    }
                }
                
            }
            Section {
                Button(action: delete) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Feed")
                    }.foregroundColor(Color.red)
                }
            }
        }
        .onDisappear(perform: save)
    }
    
    init(subscription: Feed, pages: FetchedResults<Page>, onDelete: @escaping () -> Void, onMove: @escaping () -> Void) {
        self.feed = subscription
        self.pages = pages
        self.onDelete = onDelete
        self.onMove = onMove
    }
    
    func save() {
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
    
    func delete() {
        self.viewContext.delete(self.feed)
        self.onDelete()
    }
    
    func copyFeed() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = feed.url!.absoluteString
    }
}
