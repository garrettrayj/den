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
    @Binding var userColorScheme: UserColorScheme
    @Binding var contentSelection: DetailPanel?

    @State private var showCrashMessage = false

    var body: some View {
        Group {
            if let profile = activeProfile, profile.managedObjectContext != nil {
                SplitView(
                    profile: profile,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    appProfileID: $appProfileID,
                    activeProfile: $activeProfile,
                    userColorScheme: $userColorScheme,
                    contentSelection: $contentSelection
                )
            } else {
                LoadProfile(
                    activeProfile: $activeProfile,
                    appProfileID: $appProfileID
                )
            }
        }
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
            showCrashMessage = true
        }
        .sheet(isPresented: $showCrashMessage) {
            CrashMessage()
                .interactiveDismissDisabled()
        }
        .scrollContentBackground(.hidden)
    }
}
