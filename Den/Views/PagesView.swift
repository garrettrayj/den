//
//  PagesView.swift
//  Den
//
//  Created by Garrett Johnson on 6/27/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PagesView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var safariManager: LinkManager
    
    @ObservedObject var mainViewModel: MainViewModel
    
    
    var body: some View {
        NavigationView {
            // Sidebar
            SidebarView(mainViewModel: mainViewModel)
                
            // Default view for detail area
            WelcomeView()
        }
        .sheet(isPresented: $mainViewModel.showingPageSheet) {
            VStack {
                if mainViewModel.pageSheetMode == .pageSettings {
                    PageSettingsView(mainViewModel: mainViewModel)
                } else if mainViewModel.pageSheetMode == .feedPreferences {
                    FeedWidgetSettingsView(mainViewModel: mainViewModel)
                } else if mainViewModel.pageSheetMode == .subscribe {
                    SubscribeView(page: mainViewModel.activePage ?? mainViewModel.activeProfile!.pagesArray.first)
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
