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
    @Binding var currentProfile: Profile?
    @Binding var userColorScheme: UserColorScheme
    @Binding var feedRefreshTimeout: Double
    @Binding var showingImporter: Bool
    @Binding var showingExporter: Bool

    @State private var showingCrashMessage = false
    
    @AppStorage("CurrentProfileID") private var currentProfileID: String?

    var body: some View {
        Group {
            if let profile = currentProfile, profile.managedObjectContext != nil {
                SplitView(
                    profile: profile,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    currentProfile: $currentProfile,
                    userColorScheme: $userColorScheme,
                    feedRefreshTimeout: $feedRefreshTimeout,
                    showingImporter: $showingImporter,
                    showingExporter: $showingExporter
                )
            } else {
                LoadProfile(
                    currentProfile: $currentProfile,
                    currentProfileID: $currentProfileID
                )
            }
        }
        .onChange(of: currentProfile) { _ in
            currentProfileID = currentProfile?.id?.uuidString
        }
        .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
            showingCrashMessage = true
        }
        .sheet(isPresented: $showingCrashMessage) {
            CrashMessage().interactiveDismissDisabled()
        }
    }
}
