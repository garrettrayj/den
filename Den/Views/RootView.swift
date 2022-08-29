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

    @Binding var activeProfile: Profile?

    let persistentContainer: NSPersistentContainer

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
                if activeProfile?.id == nil {
                    ProfileNotAvailableView()
                } else {
                    // Enforce stack navigation on phones to workaround dissapearing bottom toolbar
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        NavigationView {
                            SidebarView(
                                activeProfile: $activeProfile,
                                profile: activeProfile!,
                                persistentContainer: persistentContainer
                            )
                            WelcomeView()
                        }.navigationViewStyle(.stack)
                    } else {
                        NavigationView {
                            SidebarView(
                                activeProfile: $activeProfile,
                                profile: activeProfile!,
                                persistentContainer: persistentContainer
                            )
                            WelcomeView()
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .showSubscribe, object: nil)) { notification in
                if let urlString = notification.userInfo?["urlString"] as? String {
                    subscribeURLString = urlString
                }
                if let pageObjectID = notification.userInfo?["pageObjectID"] as? NSManagedObjectID {
                    subscribePageObjectID = pageObjectID
                }
                showSubscribe = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
                showCrashMessage = true
            }
            .sheet(isPresented: $showSubscribe) {
                SubscribeView(
                    initialPageObjectID: $subscribePageObjectID,
                    initialURLString: $subscribeURLString,
                    profile: activeProfile,
                    persistentContainer: persistentContainer
                ).environment(\.colorScheme, colorScheme)
            }
        }
    }
}
