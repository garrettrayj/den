//
//  ProfilesSettingsTab.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilesSettingsTab: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>
    
    @State private var selectedProfile: Profile?

    var body: some View {
        GeometryReader { geometry in
            VStack {
                #if os(macOS)
                HSplitView {
                    List(selection: $selectedProfile) {
                        ForEach(profiles, id: \.self) { profile in
                            Label {
                                profile.nameText
                            } icon: {
                                Image(systemName: profile == activeProfile ? "hexagon.fill" : "hexagon")
                                    .foregroundColor(profile.tintColor)
                            }
                            .tag(profile as Profile?)
                        }
                    }
                    .listStyle(.sidebar)
                    .frame(maxWidth: 160, maxHeight: .infinity)
                    .safeAreaInset(edge: .bottom) {
                        Button {
                            withAnimation {
                                addProfile()
                            }
                        } label: {
                            Label {
                                Text("New Profile", comment: "Button label.").lineLimit(1)
                            } icon: {
                                Image(systemName: "plus.circle")
                            }
                        }
                        .accessibilityIdentifier("new-profile-button")
                        .padding(8)
                    }
                    
                    if let profile = selectedProfile {
                        ProfilesSettingsTabDetail(
                            profile: profile,
                            appProfileID: $appProfileID,
                            activeProfile: $activeProfile,
                            isActive: activeProfile == profile,
                            deleteCallback: {
                                DispatchQueue.main.async {
                                    selectedProfile = profiles.first
                                }
                            }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .cornerRadius(8)
                #endif
            }
            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                selectedProfile = activeProfile
            }
        }
    }

    func addProfile() {
        _ = Profile.create(in: viewContext)

        do {
            try viewContext.save()
        } catch let error as NSError {
            CrashUtility.handleCriticalError(error)
        }
    }
}
