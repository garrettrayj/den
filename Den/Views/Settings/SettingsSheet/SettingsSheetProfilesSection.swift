//
//  SettingsSheetProfilesSection.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsSheetProfilesSection: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Section {
            ForEach(profiles) { profile in
                SettingsSheetProfilesSectionRow(
                    profile: profile,
                    appProfileID: $appProfileID,
                    activeProfile: $activeProfile
                )
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
