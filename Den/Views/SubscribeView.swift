//
//  SubscribeView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SubscribeView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var urlText: String = ""
    @State private var urlIsValid: Bool?
    @State private var validationAttempts: Int = 0
    @State private var validationMessage: String?
    
    var page: Page?
    
    var body: some View {
        
        
        
        VStack(alignment: .center, spacing: 20) {
            Text("Add Subscription").font(.title)
            
            if page != nil {
                HStack {
                    TextField("https://example.com/feed.xml", text: $urlText)
                        .lineLimit(1)
                        .disableAutocorrection(true)
                    
                    if urlIsValid != nil {
                        if urlIsValid == true {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(UIColor.systemGreen))
                                
                        } else {
                            Image(systemName: "slash.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(UIColor.systemRed))
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .modifier(ShakeModifier(animatableData: CGFloat(validationAttempts)))

                Button(action: validateUrl) { Text("Add to \(page!.wrappedName)") }
                .disabled(!(urlText.count > 0))
                .buttonStyle(ActionButtonStyle())
                
                if validationMessage != nil {
                    Text(validationMessage!)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                    Text("Create a page before adding subscriptions.")
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            Button(action: cancel) {
                Text("Cancel")
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(32)
        .background(Color(UIColor.secondarySystemBackground))
        .onAppear {
            self.urlText = self.subscriptionManager.subscribeURLString
        }
        .onDisappear {
            self.subscriptionManager.reset()
        }
    }
    
    func cancel() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func failValidation(message: String) {
        self.urlIsValid = false
        self.validationMessage = message
        
        withAnimation(.default) { self.validationAttempts += 1 }
    }
    
    func validateUrl() {
        self.validationMessage = nil
        self.urlIsValid = nil
        
        if self.urlText == "" {
            self.failValidation(message: "URL cannot be blank")
            return
        }
        
        if self.urlText.contains(" ") {
            self.failValidation(message: "URL cannot contain spaces")
            return
        }
        
        if self.urlText.prefix(7).lowercased() != "http://" && self.urlText.prefix(8).lowercased() != "https://" {
            self.failValidation(message: "URL must begin with \"http://\" or \"https://\"")
            return
        }
        
        guard let url = URL(string: self.urlText) else {
            self.failValidation(message: "Unable to parse URL")
            return
        }
        
        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: "URL is unopenable")
            return
        }
        
        self.urlIsValid = true
        
        self.createSubscription()
    }
    
    func createSubscription() {
        guard let targetPage = page else { return }
        
        let newSubscription = Subscription.create(
            in: self.viewContext,
            page: targetPage,
            prepend: true
        )
        newSubscription.url = URL(string: self.urlText)
        
        self.refreshManager.refresh(newSubscription)
        self.presentationMode.wrappedValue.dismiss()
    }
}
