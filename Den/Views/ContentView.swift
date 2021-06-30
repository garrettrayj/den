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
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var safariManager: LinkManager
    
    @ObservedObject var mainViewModel: MainViewModel
    
    
    var body: some View {
        TabView {
            PagesView(mainViewModel: mainViewModel)
                .tabItem { Label("Pages", systemImage: "list.dash") }
            
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
            
            HistoryView(mainViewModel: mainViewModel)
                .tabItem { Label("History", systemImage: "clock") }
            
            SettingsView(mainViewModel: mainViewModel)
                .tabItem { Label("Settings", systemImage: "gear") }
        
        }
    }
}
