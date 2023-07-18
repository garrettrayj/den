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

    @Binding var currentProfileID: String?
    
    let profiles: FetchedResults<Profile>

    @State private var profileLoadAttempts = 0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                    if profiles.isEmpty {
                        Text("No Profiles Available").font(.title2)
                    } else {
                        Text("Choose Profile").font(.title2)
                    }
                    
                    if profiles.isEmpty {
                        VStack(spacing: 16) {
                            ProgressView()
                            Text("""
                            If you have used the app before then synchronization could be in progress. \
                            Please wait a minute.
                            """, comment: "Launch guidance message.")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            
                            Text(
                                "If you're new or have disabled cloud sync then create a profile to begin.",
                                comment: "Launch guidance message."
                            )
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                        }
                        .padding()
                    } else {
                        VStack(spacing: 0) {
                            ForEach(profiles) { profile in
                                if profile != profiles.first {
                                    Divider()
                                }
                                Button {
                                    currentProfileID = profile.id?.uuidString
                                } label: {
                                    HStack {
                                        ProfileLabel(profile: profile, currentProfileID: $currentProfileID)
                                        Spacer()
                                        ButtonChevron()
                                    }
                                    .font(.title3)
                                    .padding()
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: 240)
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Button {
                        _ = createDefaultProfile()
                    } label: {
                        Text("Create a New Profile", comment: "Button label.").padding(8)
                    }.buttonStyle(.borderedProminent)
                    
                    Spacer()
                }
                .padding()
                .frame(minHeight: geometry.size.height)
            }
            .frame(maxWidth: .infinity)
            .background(.thickMaterial)
            .task {
                if profiles.count == 1 {
                    currentProfileID = profiles.first?.id?.uuidString
                }
            }
        }
    }

    var oldbody: some View {
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
                .accessibilityIdentifier("CreateProfile")
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

        if
            let profile =
                profiles.firstMatchingID(currentProfileID) ??
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
    }

    private func activateProfile(_ profile: Profile?) {
        currentProfileID = profile?.id?.uuidString
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
