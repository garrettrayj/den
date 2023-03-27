//
//  RootView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import OSLog
import SwiftUI

struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme

    @Binding var backgroundRefreshEnabled: Bool
    @Binding var appProfileID: String?
    @Binding var activeProfile: Profile?

    @State private var showCrashMessage = false
    @State private var profileLoadAttempts = 0
    @State private var profileMissing = true

    @AppStorage("UIStyle") private var uiStyle = UIUserInterfaceStyle.unspecified

    var body: some View {
        Group {
            if showCrashMessage {
                CrashMessage()
            } else if let profile = activeProfile {
                if profile.managedObjectContext == nil {
                    Text("Profile Deleted").onAppear { loadProfile() }
                } else {
                    SplitView(
                        profile: profile,
                        activeProfile: $activeProfile,
                        appProfileID: $appProfileID,
                        backgroundRefreshEnabled: $backgroundRefreshEnabled,
                        uiStyle: $uiStyle
                    )
                }
            } else {
                VStack(spacing: 16) {
                    Spacer()
                    ProgressView()
                    // After 12 seconds, give the option to create a new profile.
                    // The app will continue attempting to load an existing profile.
                    // It usually takes 30 to 40 seconds to sort things out and recover profiles from the cloud.
                    // While this isn't an ideal introduction to the app, it resolves a glaring bug.
                    // Trying to automatically create profiles has always led to duplicates historically.
                    if profileLoadAttempts > 3 {
                        Text("Profile Not Found")
                        Button {
                            activateProfile(ProfileUtility.createDefaultProfile(context: viewContext))
                        } label: {
                            Text("Create New Profile")
                        }
                        .buttonStyle(AccentButtonStyle())
                        .accessibilityIdentifier("create-profile-button")
                        Text("""
                        If you have used the app before then synchronization could be in progress. \
                        Please wait a minute.
                        """)
                        .multilineTextAlignment(.center)
                        .font(.caption)
                    } else {
                        Text("Loading…").foregroundColor(Color(.secondaryLabel)).onAppear { loadProfile() }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom)
            }
        }
        .preferredColorScheme(ColorScheme(uiStyle))
        .onChange(of: uiStyle) { _ in
            WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
        }
        .task {
            guard let window = WindowFinder.current() else { return }
            window.overrideUserInterfaceStyle = uiStyle
        }
        .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
            showCrashMessage = true
        }
    }

    private func loadProfile() {
        profileLoadAttempts += 1

        do {
            if
                let profiles = try viewContext.fetch(Profile.fetchRequest()) as? [Profile],
                let profile =
                    profiles.firstMatchingID(appProfileID ?? "") ??
                    profiles.first,
                profile.managedObjectContext != nil
            {
                activateProfile(profile)
                Logger.main.info("\(profile.displayName) profile loaded")
            } else {
                let attempt = NumberFormatter.localizedString(
                    from: profileLoadAttempts as NSNumber,
                    number: .ordinal
                )
                Logger.main.info("Could not load profile on \(attempt) attempt. Trying again...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    loadProfile()
                }
            }
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func activateProfile(_ profile: Profile) {
        appProfileID = profile.id?.uuidString
        activeProfile = profile
    }
}
