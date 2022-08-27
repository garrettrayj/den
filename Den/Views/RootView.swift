//
//  RootView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct RootView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?
    @State private var showCrashMessage = false
    @State private var crashMessage: String = ""

    var body: some View {
        if showCrashMessage {
            CrashMessageView(message: crashMessage)
        } else {
            Group {
                // Enforce stack navigation on phones to workaround dissapearing bottom toolbar
                if UIDevice.current.userInterfaceIdiom == .phone {
                    NavigationView {
                        SidebarView()
                        WelcomeView()
                    }.navigationViewStyle(.stack)
                } else {
                    NavigationView {
                        SidebarView()
                        WelcomeView()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .showSubscribe, object: nil)) { _ in
                showSubscribe = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
                showCrashMessage = true
            }
            .sheet(isPresented: $showSubscribe) {
                SubscribeView()
                    .environment(\.colorScheme, colorScheme)
                    .environmentObject(profileManager)
                    .environmentObject(crashManager)
                    .environmentObject(subscriptionManager)
                    .environmentObject(refreshManager)
            }
        }
    }
}
