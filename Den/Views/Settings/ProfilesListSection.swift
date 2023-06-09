//
//  ProfilesSettingsSection.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilesListSection: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var activeProfile: Profile?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Section {
            ForEach(profiles) { profile in
                NavigationLink(value: SubDetailPanel.profileSettings(profile)) {
                    Label {
                        profile.nameText
                    } icon: {
                        Image(systemName: profile == activeProfile ? "hexagon.fill" : "hexagon")
                            .foregroundColor(profile.tintColor)
                    }
                }
                .modifier(FormRowModifier())
                .accessibilityIdentifier("profile-button")
            }
            Button {
                withAnimation {
                    addProfile()
                }
            } label: {
                Label {
                    Text("Add Profile", comment: "Button label.")
                } icon: {
                    Image(systemName: "plus")
                }
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("add-profile-button")
        } header: {
            Text("Profiles", comment: "Settings section header.").modifier(FirstFormHeaderModifier())
        }
        .modifier(ListRowModifier())
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
