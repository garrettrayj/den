//
//  RootView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct RootView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.persistentContainer) private var container

    @ObservedObject var appState: AppState
    
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var uiStyle: UIUserInterfaceStyle

    @StateObject private var searchModel = SearchModel()

    @State private var selection: Panel?
    @State private var path = NavigationPath()
    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?
    @State private var showCrashMessage = false
    @State private var crashMessage: String = ""

    var body: some View {
        if showCrashMessage {
            CrashMessageView(message: crashMessage)
        } else if let profile = appState.activeProfile {
            NavigationSplitView {
                SidebarView(
                    profile: profile,
                    appState: appState,
                    searchModel: searchModel,
                    selection: $selection
                )
                .id(profile.id) // Fix for updating sidebar when profile changes
                .navigationSplitViewColumnWidth(268)
            } detail: {
                DetailView(
                    activeProfile: $appState.activeProfile,
                    refreshing: $appState.refreshing,
                    selection: $selection,
                    uiStyle: $uiStyle,
                    autoRefreshEnabled: $autoRefreshEnabled,
                    autoRefreshCooldown: $autoRefreshCooldown,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    profile: profile,
                    searchModel: searchModel
                )
            }
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
            .sheet(isPresented: $showSubscribe) {
                SubscribeView(
                    initialPageObjectID: $subscribePageObjectID,
                    initialURLString: $subscribeURLString,
                    profile: appState.activeProfile
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
        }
    }
}
