//
//  SplitView.swift
//  Den
//
//  Created by Garrett Johnson on 5/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct SplitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var backgroundRefreshEnabled: Bool
    @Binding var currentProfileID: String?
    @Binding var userColorScheme: UserColorScheme
    @Binding var feedRefreshTimeout: Int

    let profiles: FetchedResults<Profile>
    let refreshProgress: Progress = Progress()

    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var exporterIsPresented: Bool = false
    @State private var opmlFile: OPMLFile?
    @State private var refreshing: Bool = false
    @State private var showingImporter: Bool = false
    @State private var showingExporter: Bool = false

    @StateObject private var navigationStore = NavigationStore()

    @SceneStorage("ShowingNewFeedSheet") private var showingNewFeedSheet: Bool = false
    @SceneStorage("NewFeedWebAddress") private var newFeedWebAddress: String = ""
    @SceneStorage("NewFeedPageID") private var newFeedPageID: String?
    @SceneStorage("ShowingProfileSettings") private var showingProfileSettings: Bool = false
    @SceneStorage("DetailPanel") private var detailPanel: DetailPanel?
    @SceneStorage("Navigation") private var navigationData: Data?

    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(
                profile: profile,
                currentProfileID: $currentProfileID,
                detailPanel: $detailPanel,
                feedRefreshTimeout: $feedRefreshTimeout,
                refreshing: $refreshing,
                showingExporter: $showingExporter,
                showingImporter: $showingImporter,
                showingProfileSettings: $showingProfileSettings,
                profiles: profiles,
                refreshProgress: refreshProgress
            )
            #if os(macOS)
            .navigationSplitViewColumnWidth(220)
            #else
            .navigationSplitViewColumnWidth(272 * dynamicTypeSize.layoutScalingFactor)
            #endif
        } detail: {
            DetailView(
                profile: profile,
                detailPanel: $detailPanel,
                refreshing: $refreshing,
                path: $navigationStore.path
            )
        }
        .tint(profile.tintColor)
        .environment(\.profileTint, profile.tintColor ?? .accentColor)
        .environment(\.useSystemBrowser, useSystemBrowser)
        .onOpenURL { url in
            if case .page(let page) = detailPanel {
                NewFeedUtility.showSheet(for: url.absoluteString, profile: profile, page: page)
            } else {
                NewFeedUtility.showSheet(for: url.absoluteString, profile: profile)
            }
        }
        .modifier(
            URLDropTargetModifier(profile: profile)
        )
        .task {
            if let navigationData {
                navigationStore.restore(from: navigationData)
            }
            for await _ in navigationStore.$path.values {
                navigationData = navigationStore.encoded()
            }
        }
        .onChange(of: currentProfileID) { _ in
            detailPanel = nil
        }
        .onChange(of: detailPanel) { _ in
            navigationStore.path.removeLast(navigationStore.path.count)
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: profile.objectID)) { _ in
            refreshProgress.totalUnitCount = Int64(profile.feedsArray.count)
            refreshing = true
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed, object: profile.objectID)) { _ in
            refreshProgress.completedUnitCount += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .pagesRefreshed, object: profile.objectID)) { _ in
            refreshProgress.completedUnitCount += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)) { _ in
            refreshing = false
            refreshProgress.completedUnitCount = 0
            profile.objectWillChange.send()
            #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .showSubscribe, object: profile.objectID)) { notification in
            newFeedWebAddress = notification.userInfo?["urlString"] as? String ?? ""
            newFeedPageID = notification.userInfo?["pageID"] as? String
            showingNewFeedSheet = true
        }
        .sheet(isPresented: $showingNewFeedSheet) {
            NewFeedSheet(
                profile: profile,
                webAddress: $newFeedWebAddress,
                initialPageID: $newFeedPageID,
                feedRefreshTimeout: $feedRefreshTimeout
            )
            .tint(profile.tintColor)
            .environmentObject(refreshManager)
        }
        .sheet(
            isPresented: $showingProfileSettings,
            onDismiss: {
                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        ) {
            ProfileSettingsSheet(
                profile: profile,
                currentProfileID: $currentProfileID,
                backgroundRefreshEnabled: $backgroundRefreshEnabled,
                feedRefreshTimeout: $feedRefreshTimeout,
                useSystemBrowser: $useSystemBrowser,
                userColorScheme: $userColorScheme
            )
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.init(importedAs: "public.opml"), .xml],
            allowsMultipleSelection: false
        ) { result in
            guard let selectedFile: URL = try? result.get().first else { return }
            ImportExportUtility.importOPML(url: selectedFile, context: viewContext, profile: profile)
        }
        .fileExporter(
            isPresented: $exporterIsPresented,
            document: opmlFile,
            contentType: UTType(importedAs: "public.opml"),
            defaultFilename: profile.exportTitle.sanitizedForFileName()
        ) { _ in
            // pass
        }
        .onChange(of: showingExporter) { _ in
            if showingExporter {
                opmlFile = ImportExportUtility.exportOPML(profile: profile)
            }
            exporterIsPresented = showingExporter
        }
        
        .navigationTitle(profile.nameText)
    }
}
