//
//  FeedOptionsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedOptionsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var feed: Feed
    @State private var pickedPage: Int

    var onDelete: () -> Void
    var onMove: () -> Void
    var workspacePageArray: Array<Page>
    
    var body: some View {
        let pagePickerSelection = Binding<Int>(get: {
            return self.pickedPage
        }, set: {
            self.pickedPage = $0
            self.feed.page = self.workspacePageArray[$0]
            self.onMove()
        })
        
        let showThumbnailsToggleIsOn = Binding<Bool>(
            get: { self.feed.showThumbnails },
            set: { self.feed.showThumbnails = $0; self.feed.showLargePreviews = false }
        )
        
        let showLargePreviewsToggleIsOn = Binding<Bool>(
            get: { self.feed.showLargePreviews },
            set: { self.feed.showLargePreviews = $0; self.feed.showThumbnails = false }
        )
        
        return Form {
            Section(header: Text("TITLE")) {
                TextField("Title", text: $feed.wrappedTitle)
            }
            
            Section(header: Text("SETTINGS")) {
                Picker(selection: pagePickerSelection, label: Text("Page")) {
                    ForEach(0 ..< workspacePageArray.count) {
                        Text(self.workspacePageArray[$0].wrappedName).tag($0)
                    }.navigationBarTitle("Select Page")
                }.navigationBarTitle("Feed Options", displayMode: .inline)
                
                HStack {
                    Text("Item Limit")
                    Spacer()
                    Stepper("\(feed.itemLimit)", value: $feed.itemLimit, in: 1...10).frame(maxWidth: 120)
                }
                
                HStack {
                    Toggle(isOn: showThumbnailsToggleIsOn) {
                        Text("Show Thumbnails")
                    }
                }
                
                HStack {
                    Toggle(isOn: showLargePreviewsToggleIsOn) {
                        Text("Show Large Images")
                    }
                }
            }
            
            Section(header: Text("INFORMATION")) {
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
                    if feed.refreshed != nil {
                        Text("\(feed.refreshed!, formatter: DateFormatter.create())").foregroundColor(.secondary)
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
        .padding(.top)
        .navigationBarTitle("Feed Options", displayMode: .inline)
        .onDisappear {
            if self.viewContext.hasChanges {
                do {
                    try self.viewContext.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    init(feed: Feed, onDelete: @escaping () -> Void, onMove: @escaping () -> Void) {
        self.feed = feed
        self.onDelete = onDelete
        self.onMove = onMove
    
        guard
            let currentPage = feed.page,
            let workspace = currentPage.workspace,
            let currentPageIndex = workspace.pagesArray.firstIndex(of: currentPage)
        else {
            // Feed was deleted; set dummy data
            self.workspacePageArray = []
            _pickedPage = State(initialValue: 0)
            return
        }
        
        self.workspacePageArray = workspace.pagesArray
        _pickedPage = State(initialValue: currentPageIndex)
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

struct FeedOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        FeedOptionsView(feed: Feed(), onDelete: {}, onMove: {})
    }
}
