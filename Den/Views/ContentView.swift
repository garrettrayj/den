//
//  ContentView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var safariManager: SafariManager
    
    @FetchRequest(entity: Page.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)])
    var pages: FetchedResults<Page>
    
    var body: some View {
        NavigationView {
            // Sidebar
            SidebarView(pages: pages)
                .sheet(isPresented: $subscriptionManager.showSubscribe) {
                    if self.pages.count > 0 {
                        SubscribeView(pages: pages)
                            .environment(\.managedObjectContext, viewContext)
                            .environmentObject(subscriptionManager)
                            .environmentObject(refreshManager)
                            .environmentObject(crashManager)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                            Text("Page Required").font(.title)
                            Text("Create a page before adding subscriptions")
                                .foregroundColor(Color(.secondaryLabel))
                                .multilineTextAlignment(.center)
                            Button(action: { self.subscriptionManager.reset() }) {
                                Text("Close").fontWeight(.medium)
                            }.buttonStyle(BorderedButtonStyle())
                        }
                    }
                }
            
            // Default view for detail area
            WelcomeView(pages: pages)
        }
        .sheet(isPresented: $crashManager.showingAlert) {
            VStack(spacing: 16) {
                Image(systemName: "ladybug").resizable().scaledToFit().frame(width: 48, height: 48)
                Text("Application Crashed").font(.title)
                Text("A critical error occurred. Quit the app and restart to try again. Please consider sending a bug report if you see this repeatedly.")
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
            }.padding()
        }
    }
}
