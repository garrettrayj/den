//
//  SubscribeView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SubscribeView: View {
    enum SubscribeStage {
        case urlEntry, configuration
    }
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var screenManager: ScreenManager
    
    @State private var activeStage: SubscribeStage = .urlEntry
    @State private var urlText: String = ""
    @State private var urlIsValid: Bool?
    @State private var validationMessage: String?
    @State private var newFeed: Feed?
    
    var pages: FetchedResults<Page>
    
    var body: some View {
        VStack {
            NavigationView {
                if activeStage == .urlEntry {
                    urlEntryStage
                } else if activeStage == .configuration {
                    configurationStage
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
        .onDisappear {
            self.screenManager.resetSubscribe()
        }
    }
    
    var urlEntryStage: some View {
        Form {
            Section(header: Text("FEED URL"), footer: Text("RSS, Atom or JSON Feed")) {
                HStack {
                    TextField("https://example.com/feed.xml", text: $urlText, onEditingChanged: validateUrl)
                        .lineLimit(1)
                        .disableAutocorrection(true)
                    
                    if urlIsValid == true {
                        Image(systemName: "checkmark").foregroundColor(Color.green)
                    }
                }
            }
            
            if self.urlIsValid == false {
                Section {
                    Text(validationMessage ?? "Unknown validation error")
                }
            }
        }
        .navigationBarTitle("Add Feed", displayMode: .inline)
        .navigationBarItems(
            leading: Button(action: cancel) {
                Text("Cancel")
            },
            trailing: Button(action: createFeed) {
                HStack {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
            }
        )
        .onAppear {
            self.urlText = self.screenManager.subscribeURLString
        }
    }
    
    
    var configurationStage: some View {
        Group {
            if self.newFeed != nil && refreshManager.isRefreshing([self.newFeed!]) {
                VStack {
                    Text("Downloading feed…").font(.title)
                    ActivityRep()
                }
            } else {
                if self.newFeed != nil && self.newFeed?.error == nil {
                    FeedOptionsView(feed: self.newFeed!, onDelete: cancel, onMove: {})
                        .navigationBarItems(
                            leading: Button(action: cancel) { Text("Cancel") },
                            trailing: Button(action: save) { Text("Save") }
                        )
                } else {
                    VStack(alignment: .center, spacing: 16) {
                        Image(systemName: "slash.circle").resizable().scaledToFit().frame(width: 48, height: 48).foregroundColor(.red)
                        Text("Download Error").font(.title)
                        Text(newFeed?.error ?? "Unknown error").foregroundColor(.red).padding()
                        Button(action: back) { Text("Back").fontWeight(.medium) }
                        Button(action: cancel) { Text("Cancel").fontWeight(.medium) }
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .padding()
                }
            }
        }
    }
    
    func back() {
        self.urlIsValid = nil
        self.activeStage = .urlEntry
    }
    
    func cancel() {
        if let newFeed = self.newFeed {
            viewContext.delete(newFeed)
        }
        
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func verifyUrl(urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        
        return UIApplication.shared.canOpenURL(url)
    }
    
    func validateUrl(edit: Bool) {
        if edit == true {
            return
        }
        
        guard let url = URL(string: self.urlText) else {
            self.validationMessage = "Invalid address"
            self.urlIsValid = false
            return
        }
        
        if url.scheme == nil {
            self.validationMessage = "Address must begin with https:// or http://"
            self.urlIsValid = false
            return
        }
        
        
        if UIApplication.shared.canOpenURL(url) {
            self.validationMessage = nil
            self.urlIsValid = true
            return
        }
    }
    
    func createFeed() {
        if let exisitingNewFeed = self.newFeed {
            self.viewContext.delete(exisitingNewFeed)
            do {
                try viewContext.save()
            } catch {
                fatalError("Error saving view context after deleting existing newFeed: \(error)")
            }
        }
        
        self.newFeed = Feed.create(in: self.viewContext, page: self.screenManager.currentPage ?? self.pages.first!, prepend: true)
        self.newFeed!.url = URL(string: self.urlText.trimmingCharacters(in: .whitespacesAndNewlines))
        
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unable to create feed \(nserror), \(nserror.userInfo)")
            }
        }
        
        self.activeStage = .configuration
        self.refreshManager.refresh([newFeed!])
    }
    
    func save() {
        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        if let pageWithNewFeed = self.newFeed?.page {
            self.screenManager.activeScreen = pageWithNewFeed.id?.uuidString
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
}
