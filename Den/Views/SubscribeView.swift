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
        case urlEntry, status, configuration
    }
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var page: Page
    
    @State private var activeStage: SubscribeStage = .urlEntry
    @State private var urlText: String = ""
    @State private var urlIsValid: Bool?
    @State private var validationMessage: String?
    @State private var newFeed: Feed = Feed()
    
    var feedForm: some View {
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
    
    var statusStage: some View {
        VStack(spacing: 24) {
            Image(systemName: "tray.and.arrow.down").resizable().scaledToFit().frame(width: 128).font(Font.title.weight(.ultraLight))
            Text("Downloading feed...")
        }
    }
    
    var configForm: some View {
        NavigationView {
            FeedOptionsView(feed: newFeed, onDelete: cancel, onMove: {})
                .navigationBarItems(
                    leading: Button(action: cancel) { Text("Cancel") },
                    trailing: Button(action: save) { Text("Save") }
                )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    var body: some View {
        VStack {
            if activeStage == .urlEntry {
                feedForm
            } else if activeStage == .status {
                statusStage
            } else if activeStage == .configuration {
                configForm
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
        self.activeStage = .status
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.newFeed = Feed.create(in: self.viewContext, page: self.page)
            self.newFeed.url = URL(string: self.urlText.trimmingCharacters(in: .whitespacesAndNewlines))
            //let feedUpdater = FeedUpdater(feeds: [self.newFeed])
            //feedUpdater.start()
            
            DispatchQueue.main.async {
                self.activeStage = .configuration
            }
        }
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

struct SubscribeView_Previews: PreviewProvider {
    static var previews: some View {
        SubscribeView(page: Page())
    }
}
