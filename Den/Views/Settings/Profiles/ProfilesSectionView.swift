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
    @Binding var activeProfile: Profile?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Section {
            ForEach(profiles) { profile in
                NavigationLink(value: DetailPanel.profile(profile)) {
                    Label(
                        profile.displayName,
                        systemImage: profile == activeProfile ? "hexagon.fill" : "hexagon"
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
        var profileName = "Untitled"
        var suffix = 2
        while profiles.contains(where: { $0.name == profileName }) {
            profileName = "Untitled \(suffix)"
            suffix += 1
        }

        let profile = Profile.create(in: viewContext)
        profile.name = profileName

        do {
            try viewContext.save()
        } catch let error as NSError {
            CrashManager.handleCriticalError(error)
        }
    }

}
