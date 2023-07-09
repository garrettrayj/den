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
    @Binding var activeProfile: Profile?
    @Binding var userColorScheme: UserColorScheme
    @Binding var feedRefreshTimeout: Double
    @Binding var showingImporter: Bool
    @Binding var showingExporter: Bool

    @State private var showingCrashMessage = false
    
    @AppStorage("AppProfileID") private var appProfileID: String?

    var body: some View {
        Group {
            if let profile = activeProfile, profile.managedObjectContext != nil {
                SplitView(
                    profile: profile,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    activeProfile: $activeProfile,
                    userColorScheme: $userColorScheme,
                    feedRefreshTimeout: $feedRefreshTimeout,
                    showingImporter: $showingImporter,
                    showingExporter: $showingExporter
                )
            } else {
                LoadProfile(
                    activeProfile: $activeProfile,
                    appProfileID: $appProfileID
                )
            }
        }
        .onChange(of: activeProfile) { _ in
            appProfileID = activeProfile?.id?.uuidString
        }
        .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
            showingCrashMessage = true
        }
        .sheet(isPresented: $showingCrashMessage) {
            CrashMessage().interactiveDismissDisabled()
        }
    }
}
