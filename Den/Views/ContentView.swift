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
    
    @FetchRequest(entity: Page.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)])
    var pages: FetchedResults<Page>
    
    var body: some View {
        NavigationView {
            // Sidebar
            SidebarView(pages: pages)
                .sheet(isPresented: $subscriptionManager.showSubscribe) {
                    if self.pages.count > 0 {
                        SubscribeView(pages: self.pages)
                            .environment(\.managedObjectContext, self.viewContext)
                            .environmentObject(self.subscriptionManager)
                            .environmentObject(self.refreshManager)
                    } else {
                        VStack(spacing: 16) {
                            Text("Page Required").font(.title)
                            Text("Create a new page before subscribing to feeds.")
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
            VStack() {
                Image(systemName: "ladybug").resizable().scaledToFit().frame(width: 48, height: 48).padding()
                Text("Application Crashed").font(.title)
                VStack {
                    Text("A critical error occurred. Quit the app and restart to try again. Please consider sending a bug report if you see this repeatedly.")
                }
                .foregroundColor(Color(.secondaryLabel))
                .padding()
                .multilineTextAlignment(.center)
            }.padding()
        }
    }
}
