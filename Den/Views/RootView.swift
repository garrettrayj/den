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

    @State private var showingCrashMessage = false

    @SceneStorage("CurrentProfileID") private var currentProfileID: String?

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name, order: .forward),
        SortDescriptor(\.created, order: .forward)
    ])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        ZStack {
            if let profile = profiles.firstMatchingID(currentProfileID) {
                SplitView(
                    profile: profile,
                    currentProfileID: $currentProfileID,
                    profiles: profiles
                )
            } else {
                Landing(currentProfileID: $currentProfileID, profiles: profiles)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .appCrashed, object: nil)) { _ in
            showingCrashMessage = true
        }
        .sheet(isPresented: $showingCrashMessage) {
            CrashMessage().interactiveDismissDisabled()
        }
    }
}
