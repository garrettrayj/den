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
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var crashManager: CrashManager
    
    @State private var activeStage: SubscribeStage = .urlEntry
    @State private var urlText: String = ""
    @State private var urlIsValid: Bool = false
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
            self.subscriptionManager.reset()
        }
    }
    
    var urlEntryStage: some View {
        Form {
            Section(header: Text("Feed URL"), footer: Text("RSS, Atom or JSON Feed")) {
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
                if validationMessage != nil {
                    Section {
                        Text(validationMessage!)
                    }
                }
            }
        }
        .navigationTitle("Add Feed")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button(action: cancel) {
                Text("Cancel")
            },
            trailing: Button(action: createFeed) {
                HStack {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
            }.disabled(!urlIsValid)
        )
        .onAppear {
            self.urlText = self.subscriptionManager.subscribeURLString
        }
    }
    
    var configurationStage: some View {
        Group {
            if self.newFeed != nil && refreshManager.refreshing {
                VStack {
                    Text("Downloading feed…").font(.title)
                    ActivityRep()
                }
            } else {
                if self.newFeed != nil && self.newFeed?.error == nil {
                    FeedSettingsFormView(feed: self.newFeed!, onDelete: cancel, onMove: {})
                        .navigationBarItems(
                            leading: Button(action: cancel) { Text("Cancel") },
                            trailing: Button(action: save) { Text("Save") }
                        )
                } else {
                    VStack(alignment: .center) {
                        Image(systemName: "slash.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(Color(.systemRed))
                            .padding(.bottom)
                        Text("Download Error").font(.title)
                        Text(newFeed?.error ?? "Unknown error").foregroundColor(Color(.secondaryLabel)).padding()
                    }
                    .navigationBarItems(
                        leading: Button(action: back) {
                            Image(systemName: "chevron.backward").imageScale(.medium)
                            Text("Back").fontWeight(.medium)
                        },
                        trailing: Button(action: cancel) { Text("Cancel").fontWeight(.medium) }
                    )
                    
                    .buttonStyle(BorderedButtonStyle())
                    .padding()
                }
            }
        }
    }
    
    func back() {
        self.urlIsValid = false
        self.activeStage = .urlEntry
    }
    
    func cancel() {
        if let newFeed = self.newFeed {
            viewContext.delete(newFeed)
        }
        
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func validateUrl(edit: Bool) {
        
        if self.urlText == "" {
            self.validationMessage = nil
            self.urlIsValid = false
            return
        }
        
        if self.urlText.contains(" ") {
            self.validationMessage = "Address may not contain spaces"
            self.urlIsValid = false
            return
        }
        
        if self.urlText.prefix(7).lowercased() != "http://" && self.urlText.prefix(8).lowercased() != "https://" {
            self.validationMessage = "Address must begin with http:// or https://"
            self.urlIsValid = false
            return
        }
        
        if !self.urlText.isValidURL {
            self.validationMessage = "Address is not a valid web URL"
            self.urlIsValid = false
            return
        }
        
        guard let url = URL(string: self.urlText) else {
            self.validationMessage = "Unable to parse URL"
            self.urlIsValid = false
            return
        }
        
        if !UIApplication.shared.canOpenURL(url) {
            self.validationMessage = "Unable to open URL"
            self.urlIsValid = false
            return
        }
        
        self.validationMessage = nil
        self.urlIsValid = true
    }
    
    func createFeed() {
        if let exisitingNewFeed = self.newFeed {
            self.viewContext.delete(exisitingNewFeed)
            do {
                try viewContext.save()
            } catch let error as NSError{
                crashManager.handleCriticalError(error)
            }
        }
        
        self.newFeed = Feed.create(in: self.viewContext, page: self.subscriptionManager.currentPage ?? self.pages.first!, prepend: true)
        self.newFeed!.url = URL(string: self.urlText.trimmingCharacters(in: .whitespacesAndNewlines))
        
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
        
        self.activeStage = .configuration
        self.refreshManager.refresh(newFeed!)
    }
    
    func save() {
        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
}
