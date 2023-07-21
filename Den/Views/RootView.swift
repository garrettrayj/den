//
//  RootView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase

    @Binding var backgroundRefreshEnabled: Bool
    @Binding var userColorScheme: UserColorScheme
    @Binding var feedRefreshTimeout: Int

    @State private var currentProfile: Profile? = nil
    @State private var showingCrashMessage = false
    
    @SceneStorage("CurrentProfileID") private var currentProfileID: String?

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name, order: .forward),
        SortDescriptor(\.created, order: .forward)
    ])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Group {
            if let profile = currentProfile, profile.managedObjectContext != nil {
                SplitView(
                    profile: profile,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    currentProfileID: $currentProfileID,
                    userColorScheme: $userColorScheme,
                    feedRefreshTimeout: $feedRefreshTimeout,
                    profiles: profiles
                )
            } else {
                LoadProfile(
                    currentProfileID: $currentProfileID,
                    profiles: profiles
                )
            }
        }
        .onChange(of: currentProfileID) { _ in
            // Hard rerender from root to fix profile refresh buttons and pull-to-refresh
            // being stuck on previous profile after switch.
            currentProfile = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                currentProfile = profiles.firstMatchingID(currentProfileID)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
            showingCrashMessage = true
        }
        .sheet(isPresented: $showingCrashMessage) {
            CrashMessage().interactiveDismissDisabled()
        }
    }
}
