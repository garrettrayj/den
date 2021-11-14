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
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscribeManager: SubscribeManager

    var body: some View {
        if crashManager.showingCrashMessage == true {
            CrashMessageView()
        } else {
            navigationView
        }
    }

    private var navigationView: some View {
        NavigationView {
            SidebarView(
                searchViewModel: SearchViewModel(
                    viewContext: viewContext,
                    crashManager: crashManager
                )
            )

            // Default view for detail area
            WelcomeView()
        }
        .modifier(MacButtonStyleModifier())
        .sheet(isPresented: $subscribeManager.showingAddSubscription) {
            SubscribeView(viewModel: SubscribeViewModel(
                viewContext: viewContext,
                profileManager: profileManager,
                refreshManager: refreshManager,
                subscribeManager: subscribeManager,
                urlText: subscribeManager.openedUrlString,
                destinationPageId: subscribeManager.currentPageId

            ))
            .environment(\.colorScheme, colorScheme)
        }
    }
}
