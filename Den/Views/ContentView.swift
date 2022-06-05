//
//  ContentView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var body: some View {
        if crashManager.showingCrashMessage == true {
            CrashMessageView()
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                navigationView.navigationViewStyle(.stack)
            } else {
                navigationView
            }
        }
    }

    var navigationView: some View {
        NavigationView {
            SidebarView(
                viewModel: ProfileViewModel(
                    viewContext: viewContext,
                    crashManager: crashManager,
                    profile: profileManager.activeProfile!
                )
            )

            // Default view for detail area
            WelcomeView()
        }
        .sheet(isPresented: $subscriptionManager.showingSubscribe) {
            SubscribeView(viewModel: SubscribeViewModel(
                viewContext: viewContext,
                profileManager: profileManager,
                refreshManager: refreshManager,
                urlText: subscriptionManager.feedUrlString,
                page: subscriptionManager.activePage
            ))
            .environment(\.colorScheme, colorScheme)
            .environmentObject(profileManager)
        }
    }

}
