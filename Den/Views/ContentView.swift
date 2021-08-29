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
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var crashManager: CrashManager

    var body: some View {
        if crashManager.showingCrashMessage == true {
            CrashMessageView()
        } else {
            TabView {
                PagesView().tabItem { Label("Pages", systemImage: "list.dash") }

                SearchView(
                    searchViewModel: SearchViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager
                    )
                )
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

                HistoryView(
                    historyViewModel: HistoryViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager
                    )
                )
                .tabItem { Label("History", systemImage: "clock") }

                SettingsView().tabItem { Label("Settings", systemImage: "gear") }
            }
            .buttonStyle(BorderlessButtonStyle())
            .sheet(isPresented: $subscriptionManager.showingAddSubscription) {
                SubscribeView()
                    .environment(\.managedObjectContext, viewContext)
                    .environment(\.colorScheme, colorScheme)
                    .environmentObject(subscriptionManager)
                    .environmentObject(refreshManager)
                    .environmentObject(crashManager)
            }
        }
    }
}
