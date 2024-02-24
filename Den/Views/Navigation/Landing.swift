//
//  Landing.swift
//  Den
//
//  Created by Garrett Johnson on 5/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import OSLog
import SwiftUI

struct Landing: View {
    @Environment(\.minDetailColumnWidth) private var minDetailColumnWidth
    
    @Binding var currentProfileID: String?

    let profiles: FetchedResults<Profile>

    var body: some View {
        NavigationStack {
            ZStack {
                if profiles.isEmpty {
                    noProfiles
                } else {
                    profileSelection
                }
            }
            .frame(minWidth: minDetailColumnWidth, maxWidth: .infinity, maxHeight: .infinity)
            #if os(iOS)
            .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
            #endif
        }
    }
    
    private var noProfiles: some View {
        ContentUnavailable {
            Label {
                Text("No Profiles", comment: "Landing title.")
            } icon: {
                ProgressView()
            }
        } description: {
            VStack(spacing: 16) {
                Text(
                    """
                    If you have used the app on another device \
                    then synchronization may be in progress. \
                    \nPlease wait a minute.
                    """,
                    comment: "Landing guidance message."
                )
                Text(
                    """
                    If you are new or cloud sync is disabled then create a profile to begin.
                    """,
                    comment: "Landing guidance message."
                )
            }
        } actions: {
            NewProfileButton(callback: { profile in
                currentProfileID = profile.id?.uuidString
            })
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var profileSelection: some View {
        VStack {
            Text(
                "Select Profile",
                comment: "Landing view title."
            )
            .font(.title3)
            .foregroundStyle(.secondary)

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
            .frame(maxWidth: 240)
            #if os(macOS)
            .background(.background)
            #else
            .background(Color(.secondarySystemGroupedBackground))
            #endif
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .lineLimit(1)
    }
}
