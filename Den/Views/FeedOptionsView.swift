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
    
    var imageSectionHeader: some View {
        HStack {
            Text("IMAGES")
            Spacer()
            Text("\(feed.itemsWithImageCount) ITEMS WITH IMAGES")
        }
        
        
    }
    
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
            Section {
                HStack {
                    Text("Title")
                    TextField(self.feed.title ?? "Unknown Title", text: $feed.wrappedTitle).multilineTextAlignment(.trailing)
                }
                
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
                
                
            }
            
            Section(header: imageSectionHeader) {
                HStack {
                    Toggle(isOn: showThumbnailsToggleIsOn) {
                        Text("Show Thumbnails")
                    }
                }
                
                HStack {
                    Toggle(isOn: showLargePreviewsToggleIsOn) {
                        Text("Show Large Previews")
                    }
                }
            }
            
            Section {
                HStack(alignment: .center) {
                    Text("URL")
                    Button(action: copyFeed) {
                        Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(width: 14, height: 14)
                    }
                    AdvancedTextField(text: $feed.urlString, isEditable: false, textAlignment: .right).opacity(0.5)
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
        .navigationBarTitle("Feed Options", displayMode: .inline)
    }
    
    init(feed: Feed, onDelete: @escaping () -> Void, onMove: @escaping () -> Void) {
        self.feed = feed
        self.onDelete = onDelete
        self.onMove = onMove
    
        guard
            let currentPage = feed.page,
            let workspace = currentPage.workspace,
            let currentPageIndex = workspace.pageArray.firstIndex(of: currentPage)
        else {
            // Feed was deleted; set dummy data
            self.workspacePageArray = []
            _pickedPage = State(initialValue: 0)
            return
        }
        
        self.workspacePageArray = workspace.pageArray
        _pickedPage = State(initialValue: currentPageIndex)
    }
    
    func delete() {
        self.viewContext.delete(self.feed)
        do {
            try self.viewContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
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
