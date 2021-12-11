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
    @EnvironmentObject var sourceManager: SourceManager

    var body: some View {
        if crashManager.showingCrashMessage == true {
            CrashMessageView()
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                // Fixes issue of ObservableObjects causing navigation to pop back
                // https://stackoverflow.com/a/69300858/400468
                // ...columns never looked nice on iPhone anyways
                navigationView.navigationViewStyle(.stack)
            } else {
                navigationView
            }
        }
    }

    private var navigationView: some View {
        NavigationView {
            SidebarView(
                profileViewModel: ProfileViewModel(
                    viewContext: viewContext,
                    crashManager: crashManager,
                    profile: profileManager.activeProfile!
                ),
                searchViewModel: SearchViewModel(viewContext: viewContext, crashManager: crashManager)
            )

            // Default view for detail area
            WelcomeView(profileIsEmpty: profileManager.activeProfile?.pagesArray.count ?? 0 == 0)
        }
        .modifier(MacButtonStyleModifier())
        .sheet(isPresented: $sourceManager.showingSheet) {
            SubscribeView(viewModel: SubscribeViewModel(
                viewContext: viewContext,
                profileManager: profileManager,
                refreshManager: refreshManager,
                sourceManager: sourceManager,
                urlText: sourceManager.feedUrlString,
                destinationPageId: sourceManager.currentPageId
            ))
            .environment(\.colorScheme, colorScheme)
        }
    }
}
