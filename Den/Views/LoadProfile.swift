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
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    ScrollView {
                        HStack {
                            Spacer()
                            loadingLayout
                            Spacer()
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            #if os(iOS)
            .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
            #endif
            .navigationTitle(
                profiles.isEmpty ?
                Text("No Profiles Available", comment: "Navigation title.") :
                    Text("Choose Profile", comment: "Navigation title.")
            )
            .toolbar {
                ToolbarItem {
                    NewProfileButton(currentProfileID: $currentProfileID)
                        .labelStyle(.titleAndIcon)
                        .buttonStyle(.borderedProminent)
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
    
    private var loadingLayout: some View {
        VStack(spacing: 24) {
            Spacer()
            if profiles.isEmpty {
                ProgressView()
                VStack(spacing: 16) {
                    Text("""
                    If you have used the app before then synchronization could be in progress. \
                    Please wait a minute.
                    """, comment: "Launch guidance message.")
                    .multilineTextAlignment(.center)
                    .font(.footnote)

                    Text(
                        "If you're new or have cloud sync disabled then create a profile to begin.",
                        comment: "Launch guidance message."
                    )
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                }
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
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("SelectProfile")
                        .onAppear {
                            if profiles.count == 1 {
                                currentProfileID = profile.id?.uuidString
                            }
                        }
                    }
                }
                .frame(maxWidth: 240)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Spacer()
        }
        .padding()
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

    private func createProfile() -> Profile {
        let profile = Profile.create(in: viewContext)

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }

        return profile
    }
}
