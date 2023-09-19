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

    @State private var showingCrashMessage = false
    @State private var showingNewProfileSheet = false

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
                    showingNewProfileSheet: $showingNewProfileSheet,
                    profiles: Array(profiles)
                )
                .environment(\.userTint, profile.tintColor)
            } else {
                Landing(
                    currentProfileID: $currentProfileID,
                    showingNewProfileSheet: $showingNewProfileSheet,
                    profiles: Array(profiles)
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .appCrashed, object: nil)) { _ in
            showingCrashMessage = true
        }
        .sheet(isPresented: $showingCrashMessage) {
            CrashMessage().interactiveDismissDisabled()
        }
        .sheet(
            isPresented: $showingNewProfileSheet,
            onDismiss: {
                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            },
            content: {
                NewProfileSheet(currentProfileID: $currentProfileID)
            }
        )
    }
}
