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

    @State private var appErrorMessage: String?
    @State private var showingAppErrorSheet = false

    @SceneStorage("CurrentProfileID") private var currentProfileID: String?

    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name, order: .forward),
        SortDescriptor(\.created, order: .forward)
    ])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Group {
            if let profile = profiles.firstMatchingID(currentProfileID) {
                SplitView(
                    profile: profile,
                    currentProfileID: $currentProfileID,
                    userColorScheme: $userColorScheme,
                    useSystemBrowser: $useSystemBrowser,
                    profiles: Array(profiles)
                )
                .environment(\.userTint, profile.tintColor)
            } else {
                Landing(
                    currentProfileID: $currentProfileID,
                    profiles: Array(profiles)
                )
            }
        }
        .environment(\.useSystemBrowser, useSystemBrowser)
        .preferredColorScheme(userColorScheme.colorScheme)
        .onReceive(NotificationCenter.default.publisher(for: .appErrored, object: nil)) { output in
            if let message = output.userInfo?["message"] as? String {
                appErrorMessage = message
            }
            showingAppErrorSheet = true
        }
        .sheet(isPresented: $showingAppErrorSheet) {
            AppErrorSheet(message: $appErrorMessage).interactiveDismissDisabled()
        }
    }
}
