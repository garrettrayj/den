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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme

    @Binding var backgroundRefreshEnabled: Bool
    @Binding var appProfileID: String?

    @State private var showCrashMessage = false

    @AppStorage("UIStyle") private var uiStyle = UIUserInterfaceStyle.unspecified

    @SceneStorage("ActiveProfileID") private var sceneProfileID: String?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var activeProfile: Profile? {
        guard let sceneProfileID = sceneProfileID else { return nil }
        return profiles.first(where: {$0.id?.uuidString == sceneProfileID})
    }

    var body: some View {
        VStack {
            if showCrashMessage {
                CrashMessageView()
            } else if let profile = activeProfile {
                if profile.managedObjectContext == nil {
                    Text("Profile Deleted").onAppear { loadProfile() }
                } else {
                    SplitView(
                        profile: profile,
                        backgroundRefreshEnabled: $backgroundRefreshEnabled,
                        appProfileID: $appProfileID,
                        uiStyle: $uiStyle
                    )
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
                    if activeProfile == nil {
                        loadProfile()
                    }
                }
            }
        }
        .preferredColorScheme(ColorScheme(uiStyle))
        .onChange(of: uiStyle) { _ in
            WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
        }
        .onAppear {
            guard let window = WindowFinder.current() else { return }
            window.overrideUserInterfaceStyle = uiStyle
        }
        .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
            showCrashMessage = true
        }
    }
    
    private func loadProfile() {
        let profile = profiles.first { $0.id?.uuidString == appProfileID }
                        ?? profiles.first
                        ?? ProfileUtility.createDefaultProfile(context: viewContext)
        
        sceneProfileID = profile.id?.uuidString
        appProfileID = profile.id?.uuidString
    }
}
