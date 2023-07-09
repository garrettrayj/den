//
//  LoadProfile.swift
//  Den
//
//  Created by Garrett Johnson on 5/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import OSLog
import SwiftUI

struct LoadProfile: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var currentProfile: Profile?
    @Binding var currentProfileID: String?

    @State private var profileLoadAttempts = 0

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
            // After 12 seconds, give the option to create a new profile.
            // The app will continue attempting to load an existing profile.
            // It usually takes 30 to 40 seconds to sort things out and recover profiles from the cloud.
            // While this isn't an ideal introduction to the app, it resolves a glaring bug.
            // Trying to automatically create profiles has always led to duplicates historically.
            if profileLoadAttempts > 1 {
                Text(
                    "No Profiles Found",
                    comment: "Launch status message."
                )
                Button {
                    activateProfile(createDefaultProfile())
                } label: {
                    Text("Create a New Profile", comment: "Button label.").padding(8)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("create-profile-button")
                Text("""
                If you have used the app before then synchronization could be in progress. \
                Please wait a minute.
                """, comment: "Launch guidance message.")
                .multilineTextAlignment(.center)
                .font(.footnote)
            } else {
                Text(
                    "Loading…",
                    comment: "Launch status message."
                )
                .foregroundColor(.secondary).onAppear { load() }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.bottom)
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    private func load() {
        profileLoadAttempts += 1

        do {
            if
                let profiles = try viewContext.fetch(Profile.fetchRequest()) as? [Profile],
                let profile =
                    profiles.firstMatchingID(currentProfileID ?? "") ??
                    profiles.first,
                profile.managedObjectContext != nil
            {
                activateProfile(profile)
                Logger.main.info("Profile loaded: \(profile.id?.uuidString ?? "", privacy: .public)")
            } else {
                let attempt = NumberFormatter.localizedString(
                    from: profileLoadAttempts as NSNumber,
                    number: .ordinal
                )
                Logger.main.info("Could not load profile on \(attempt) attempt. Trying again...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    load()
                }
            }
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func activateProfile(_ profile: Profile?) {
        currentProfileID = profile?.id?.uuidString
        currentProfile = profile
    }

    private func createDefaultProfile() -> Profile {
        let profile = Profile.create(in: viewContext)

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }

        return profile
    }
}
