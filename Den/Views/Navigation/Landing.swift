//
//  Landing.swift
//  Den
//
//  Created by Garrett Johnson on 5/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import OSLog
import SwiftUI

struct Landing: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var currentProfileID: String?
    @Binding var showingNewProfileSheet: Bool

    let profiles: [Profile]

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
            .toolbar {
                #if os(macOS)
                ToolbarItem {
                    NewProfileButton(showingNewProfileSheet: $showingNewProfileSheet)
                        .labelStyle(.titleAndIcon)
                        .buttonStyle(.borderedProminent)
                }
                #else
                ToolbarItem(placement: .bottomBar) {
                    NewProfileButton(showingNewProfileSheet: $showingNewProfileSheet)
                        .labelStyle(.titleAndIcon)
                        .buttonStyle(.borderedProminent)
                }
                #endif
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
                ContentUnavailableView {
                    Label {
                        Text("No Profiles Available", comment: "Landing title.")
                    } icon: {
                        ProgressView()
                    }
                } description: {
                    Text(
                        """
                        If you have used the app before then data sync could be in progress. \
                        Please wait a minute.
                        """,
                        comment: "Landing guidance message."
                    )
                    .padding(.top)
                    Text(
                         "If you're new or have disabled cloud sync then create a new profile to begin.",
                         comment: "Landing guidance message."
                    )
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
                                profile.nameText
                                Spacer()
                                ButtonChevron()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("SelectProfile")
                    }
                }
                .task {
                    if profiles.count == 1 {
                        currentProfileID = profiles.first?.id?.uuidString
                    }
                }
                .frame(maxWidth: 240)
                #if os(macOS)
                .background(.background)
                #else
                .background(Color(.secondarySystemGroupedBackground))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Spacer()
        }
        .padding(32)
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
