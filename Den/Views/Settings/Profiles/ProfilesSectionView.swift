//
//  ProfilesSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ProfilesSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var activeProfileID: String?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Section {
            ForEach(profiles) { profile in
                NavigationLink(value: SettingsPanel.profile(profile)) {
                    Label(
                        profile.displayName,
                        systemImage: profile.id?.uuidString == activeProfileID ? "hexagon.fill" : "hexagon"
                    )
                }
                .modifier(FormRowModifier())
                .accessibilityIdentifier("profile-button")
            }
            Button {
                withAnimation {
                    addProfile()
                }
            } label: {
                Label("Add Profile", systemImage: "plus")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("add-profile-button")
        } header: {
            Text("Profiles").modifier(FormFirstHeaderModifier())
        }
    }

    func addProfile() {
        var profileName = "New Profile"
        var suffix = 2
        while profiles.contains(where: { $0.name == profileName }) {
            profileName = "New Profile \(suffix)"
            suffix += 1
        }

        let profile = Profile.create(in: viewContext)
        profile.name = profileName

        do {
            try viewContext.save()
        } catch let error as NSError {
            CrashUtility.handleCriticalError(error)
        }
    }
}
