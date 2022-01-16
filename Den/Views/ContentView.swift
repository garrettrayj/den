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
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        if crashManager.showingCrashMessage == true {
            CrashMessageView()
        } else {
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
            .modifier(MacButtonStyleModifier())
            .sheet(isPresented: $subscriptionManager.showingSubscribe) {
                SubscribeView(viewModel: SubscribeViewModel(
                    viewContext: viewContext,
                    profileManager: profileManager,
                    refreshManager: refreshManager,
                    urlText: subscriptionManager.feedUrlString,
                    page: subscriptionManager.activePage
                ))
                .environment(\.colorScheme, colorScheme)
            }
        }
    }
}
