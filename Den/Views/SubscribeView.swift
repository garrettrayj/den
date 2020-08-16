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
        case urlEntry,configuration
    }
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshManager: RefreshManager
    @ObservedObject var page: Page
    @State private var activeStage: SubscribeStage = .urlEntry
    @State private var urlText: String = ""
    @State private var urlIsValid: Bool?
    @State private var validationMessage: String?
    @State private var newFeed: Feed?
    
    var body: some View {
        VStack {
            if activeStage == .urlEntry {
                urlEntryStage
            } else if activeStage == .configuration {
                configurationStage
            }
        }
    }
    
    var urlEntryStage: some View {
        NavigationView {
            Form {
                Section(footer: Text("RSS or Atom accepted")) {
                    HStack {
                        Text("Feed URL:")
                        Spacer()
                        TextField("https://example.com/feed.xml", text: $urlText, onEditingChanged: validateUrl)
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                            .disableAutocorrection(true)
                        
                        if urlIsValid == true {
                            Image(systemName: "checkmark").foregroundColor(Color.green)
                        }
                    }
                }
                
                if self.urlIsValid == false {
                    Section {
                        Text(validationMessage ?? "Unknown Validation Error")
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
            .modifier(ModalNavigationBarModifier())
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    var configurationStage: some View {
        Group {
            if self.newFeed != nil && refreshManager.isRefreshing(self.newFeed!) {
                VStack {
                    Text("Downloading...").font(.title)
                    ActivityRep()
                }
            } else {
                NavigationView {
                    FeedOptionsView(feed: self.newFeed!, onDelete: cancel, onMove: {})
                        .navigationBarItems(
                            leading: Button(action: cancel) { Text("Cancel") },
                            trailing: Button(action: save) { Text("Save") }
                        )
                }.navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
    
    func cancel() {
        if viewContext.hasChanges {
            viewContext.rollback()
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
        self.newFeed = Feed.create(in: self.viewContext, page: self.page)
        self.newFeed!.url = URL(string: self.urlText.trimmingCharacters(in: .whitespacesAndNewlines))
        
        self.activeStage = .configuration
        self.refreshManager.refresh(newFeed!)
    }
    
    func save() {        
        do {
            try viewContext.save()
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
}
