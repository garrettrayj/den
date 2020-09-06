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
    @EnvironmentObject var screenManager: ScreenManager
    @EnvironmentObject var refreshManager: RefreshManager
    
    @FetchRequest(entity: Page.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)])
    var pages: FetchedResults<Page>
    
    var body: some View {
        NavigationView {
            WorkspaceView(pages: pages)
            WelcomeView(pages: pages)
        }
        .onAppear {
            #if targetEnvironment(macCatalyst)
            if self.screenManager.activeScreen == nil {
                self.screenManager.activeScreen = self.pages.first?.id?.uuidString
            }
            #endif
        }
        .sheet(isPresented: $screenManager.showSubscribe) {
            if self.pages.count > 0 {
                SubscribeView(pages: self.pages)
                    .environment(\.managedObjectContext, self.viewContext)
                    .environmentObject(self.screenManager)
                    .environmentObject(self.refreshManager)
            } else {
                VStack(spacing: 16) {
                    Text("Page Required").font(.title)
                    Text("Create a new page before subscribing to feeds.")
                    Button(action: { self.screenManager.resetSubscribe() }) {
                        Text("Close").fontWeight(.medium)
                    }.buttonStyle(BorderedButtonStyle())
                }
            }
        }
    }
}
