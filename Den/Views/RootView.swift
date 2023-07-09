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
    @Binding var appProfileID: String?
    @Binding var activeProfile: Profile?
    @Binding var userColorScheme: UserColorScheme
    @Binding var feedRefreshTimeout: Double
    @Binding var showingImporter: Bool
    @Binding var showingExporter: Bool

    @State private var showingCrashMessage = false

    var body: some View {
        Group {
            if let profile = activeProfile, profile.managedObjectContext != nil {
                SplitView(
                    profile: profile,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    appProfileID: $appProfileID,
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
        .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
            showingCrashMessage = true
        }
        .sheet(isPresented: $showingCrashMessage) {
            CrashMessage().interactiveDismissDisabled()
        }
    }
}
