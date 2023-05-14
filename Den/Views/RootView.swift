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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase

    @Binding var backgroundRefreshEnabled: Bool
    @Binding var appProfileID: String?
    @Binding var activeProfile: Profile?

    @State private var showCrashMessage = false

    @AppStorage("UIStyle") private var uiStyle = UIUserInterfaceStyle.unspecified

    var body: some View {
        Group {
            if let profile = activeProfile, profile.managedObjectContext != nil {
                SplitView(
                    profile: profile,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    appProfileID: $appProfileID,
                    activeProfile: $activeProfile,
                    uiStyle: $uiStyle
                )
            } else {
                LoadProfile(
                    activeProfile: $activeProfile,
                    appProfileID: $appProfileID
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
            showCrashMessage = true
        }
        .sheet(isPresented: $showCrashMessage) {
            CrashMessage()
                .preferredColorScheme(ColorScheme(uiStyle))
                .interactiveDismissDisabled()
        }
        .scrollContentBackground(.hidden)
        .preferredColorScheme(ColorScheme(uiStyle))
        .onChange(of: uiStyle) { _ in
            // Update UI style override for system views, e.g., built-in Safari on iOS
            WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
        }
        .task {
            // Set initial UI style override for system views, e.g., built-in Safari on iOS
            WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
        }
    }
}
