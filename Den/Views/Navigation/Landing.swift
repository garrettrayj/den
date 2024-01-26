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
    @Binding var currentProfileID: String?

    let profiles: [Profile]

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
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem {
                    NewProfileButton()
                        .labelStyle(.titleAndIcon)
                        #if os(iOS)
                        .buttonStyle(.borderless)
                        #endif
                }
            }
        }
    }

    private var loadingLayout: some View {
        VStack(spacing: 24) {
            Spacer()
            if profiles.isEmpty {
                ContentUnavailable {
                    Label {
                        Text("No Profiles", comment: "Landing title.")
                    } icon: {
                        ProgressView()
                    }
                } description: {
                    Text(
                        """
                        If you have used the app on another device then synchronization may be in progress. \
                        Please wait a minute. \n
                        If you are new or cloud sync is disabled then create a profile to begin.
                        """,
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
        .padding()
    }
}
