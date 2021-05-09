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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var safariManager: BrowserManager
    
    @ObservedObject var mainViewModel: MainViewModel
    
    @FetchRequest(
        entity: Page.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)]
    )
    var pages: FetchedResults<Page>
    
    var body: some View {
        NavigationView {
            // Sidebar
            SidebarView(mainViewModel: mainViewModel, pages: pages)
                
            // Default view for detail area
            WelcomeView()
        }
        .onAppear {
            #if targetEnvironment(macCatalyst)
                UITableView.appearance().showsVerticalScrollIndicator = false
            #endif
        }
        .sheet(isPresented: $mainViewModel.showingPageSheet) {
            Group {
                if mainViewModel.pageSheetMode == .pageSettings {
                    PageSettingsView(mainViewModel: mainViewModel)
                } else if mainViewModel.pageSheetMode == .feedPreferences {
                    FeedWidgetSettingsView(mainViewModel: mainViewModel, pages: pages)
                } else if mainViewModel.pageSheetMode == .subscribe {
                    SubscribeView(page: mainViewModel.activePage ?? pages.first)
                } else if mainViewModel.pageSheetMode == .crashMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "ladybug").resizable().scaledToFit().frame(width: 48, height: 48)
                        Text("Application Crashed").font(.title)
                        Text("A critical error occurred. Quit the app and restart to try again. Please consider sending a bug report if you see this repeatedly.")
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)
                    }.padding()
                }
            }
            .environment(\.managedObjectContext, viewContext)
            .environment(\.colorScheme, colorScheme)
            .environmentObject(subscriptionManager)
            .environmentObject(refreshManager)
            .environmentObject(crashManager)
        }
        
    }
}
