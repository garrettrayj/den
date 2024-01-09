//
//  RootView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//

import CoreData
import OSLog
import SwiftUI

struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var appErrorMessage: String?
    @State private var showingAppErrorSheet = false

    @SceneStorage("CurrentProfileID") private var currentProfileID: String?

    @AppStorage("MaintenanceTimestamp") private var maintenanceTimestamp: Double?
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
        .task {
            await BlocklistManager.initializeMissingContentRulesLists()
            await performMaintenance()
        }
    }
    
    private func performMaintenance() async {
        if let maintenanceTimestamp = maintenanceTimestamp {
            let nextMaintenanceDate = Date(
                timeIntervalSince1970: maintenanceTimestamp
            ) + 7 * 24 * 60 * 60
            
            if nextMaintenanceDate > .now {
                Logger.main.info("""
                Next maintenance operation will be performed after \
                \(nextMaintenanceDate.formatted(), privacy: .public)
                """)
                // return
            }
        }

        for profile in profiles {
            try? CleanupUtility.removeExpiredHistory(context: viewContext, profile: profile)
            CleanupUtility.trimSearches(context: viewContext, profile: profile)
        }

        try? CleanupUtility.purgeOrphans(context: viewContext)
        
        await BlocklistManager.cleanupContentRulesLists()
        await BlocklistManager.refreshAllContentRulesLists()

        try? viewContext.save()

        maintenanceTimestamp = Date.now.timeIntervalSince1970
    }
}
