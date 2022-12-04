//
//  RootView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import SwiftUI

struct RootView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.persistentContainer) private var container
    @Environment(\.scenePhase) private var scenePhase
    
    let appState: AppState
    
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var uiStyle: UIUserInterfaceStyle

    @StateObject private var searchModel = SearchModel()

    @State private var refreshing: Bool = false
    @State private var selection: Panel?
    @State private var path = NavigationPath()
    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?
    @State private var showCrashMessage = false
    @State private var crashMessage: String = ""
    
    @AppStorage("AutoRefreshEnabled") var autoRefreshEnabled: Bool = false
    @AppStorage("AutoRefreshCooldown") var autoRefreshCooldown: Int = 30
    
    @SceneStorage("ActiveProfileID") private var activeProfileID: String?
    @SceneStorage("AutoRefreshDate") var autoRefreshDate: Double = 0.0
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>
    
    let progress = Progress()
    
    var activeProfile: Profile? {
        guard let activeProfileID = activeProfileID else { return nil }
        return profiles.first(where: {$0.id?.uuidString == activeProfileID})
    }

    var body: some View {
        if showCrashMessage {
            CrashMessageView(message: crashMessage)
        } else if let profile = activeProfile {
            NavigationSplitView {
                SidebarView(
                    profile: profile,
                    searchModel: searchModel,
                    progress: progress,
                    selection: $selection,
                    refreshing: $refreshing
                )
                .id(profile.id) // Fix for updating sidebar when profile changes
                .navigationSplitViewColumnWidth(268)
            } detail: {
                DetailView(
                    activeProfileID: $activeProfileID,
                    selection: $selection,
                    uiStyle: $uiStyle,
                    autoRefreshEnabled: $autoRefreshEnabled,
                    autoRefreshCooldown: $autoRefreshCooldown,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    profile: profile,
                    searchModel: searchModel
                )
            }
            .disabled(refreshing)
            .onOpenURL { url in
                if case .page(let page) = selection {
                    SubscriptionUtility.showSubscribe(for: url.absoluteString, page: page)
                } else {
                    SubscriptionUtility.showSubscribe(for: url.absoluteString)
                }
            }
            .modifier(
                URLDropTargetModifier()
            )
            .onAppear {
                appState.activeProfiles.insert(profile)
            }
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    Logger.main.debug("Root scene phase: active")
                    if autoRefreshEnabled && !appState.refreshing && (
                        autoRefreshDate == 0.0 ||
                        Date(timeIntervalSinceReferenceDate: autoRefreshDate) < .now - Double(autoRefreshCooldown) * 60
                    ) {
                        Task {
                            guard !refreshing, let profile = activeProfile else { return }
                            await RefreshUtility.refresh(container: container, profile: profile)
                            autoRefreshDate = Date.now.timeIntervalSinceReferenceDate
                        }
                    }
                case .inactive:
                    Logger.main.debug("Root scene phase: inactive")
                case .background:
                    Logger.main.debug("Root scene phase: background")
                @unknown default:
                    Logger.main.debug("Root scene phase: unknown")
                }
            }
            .onChange(of: selection) { _ in
                path.removeLast(path.count)
            }
            .onChange(of: uiStyle, perform: { _ in
                WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
            })
            .onReceive(NotificationCenter.default.publisher(for: .showSubscribe, object: nil)) { notification in
                subscribeURLString = notification.userInfo?["urlString"] as? String ?? ""
                subscribePageObjectID = notification.userInfo?["pageObjectID"] as? NSManagedObjectID
                showSubscribe = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
                showCrashMessage = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: profile.objectID)) { _ in
                Haptics.mediumImpactFeedbackGenerator.impactOccurred()
                progress.totalUnitCount = Int64(profile.feedsArray.count)
                progress.completedUnitCount = 0
                refreshing = true
                appState.refreshing = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
                progress.completedUnitCount += 1
            }
            .onReceive(NotificationCenter.default.publisher(for: .pagesRefreshed)) { _ in
                progress.completedUnitCount += 1
            }
            .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)) { _ in
                refreshing = false
                appState.refreshing = false
                profile.objectWillChange.send()
                Haptics.notificationFeedbackGenerator.notificationOccurred(.success)
            }
            .sheet(isPresented: $showSubscribe) {
                SubscribeView(
                    initialPageObjectID: $subscribePageObjectID,
                    initialURLString: $subscribeURLString,
                    profile: profile
                )
                .environment(\.persistentContainer, container)
                .environment(\.colorScheme, colorScheme)
            }
        } else {
            VStack(spacing: 16) {
                Spacer()
                ProgressView()
                Text("Opening…")
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .foregroundColor(Color.secondary)
            .onAppear {
                if activeProfileID == nil || activeProfile?.managedObjectContext == nil {
                    let defaultProfile = profiles
                        .filter({$0.managedObjectContext != nil})
                        .first ?? ProfileUtility.createDefaultProfile(context: container.viewContext)
                    
                    activeProfileID = defaultProfile.id?.uuidString
                }
            }
        }
    }
}
