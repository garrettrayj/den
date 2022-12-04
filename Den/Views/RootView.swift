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
    
    @Binding var backgroundRefreshEnabled: Bool

    @State private var showCrashMessage = false
    
    @AppStorage("UIStyle") private var uiStyle = UIUserInterfaceStyle.unspecified
    
    @SceneStorage("ActiveProfileID") private var activeProfileID: String?
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>
    
    var activeProfile: Profile? {
        guard let activeProfileID = activeProfileID else { return nil }
        return profiles.first(where: {$0.id?.uuidString == activeProfileID})
    }

    var body: some View {
        Group {
            if showCrashMessage {
                CrashMessageView()
            } else if let profile = activeProfile {
                ContentView(
                    profile: profile,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    uiStyle: $uiStyle
                )
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
        .preferredColorScheme(ColorScheme(uiStyle))
        .onChange(of: uiStyle) { _ in
            WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
        }
        .onAppear {
            WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
        }
        .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
            showCrashMessage = true
        }
    }
}
