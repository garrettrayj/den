//
//  ProfilesSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilesSection: View {
    @Environment(\.managedObjectContext) private var viewContext

    let profiles: [Profile]
    
    @Binding var currentProfileID: String?
    
    @State private var selection: Profile?
    @State private var showingNewProfile = false

    var body: some View {
        Section {
            ForEach(profiles) { profile in
                NavigationLink {
                    ProfileSettings(profile: profile)
                } label: {
                    Label {
                        profile.nameText
                    } icon: {
                        if profile.id?.uuidString == currentProfileID {
                            Image(systemName: "rhombus.fill")
                        } else {
                            Image(systemName: "rhombus")
                        }
                    }
                }
            }
            NewProfileButton().buttonStyle(.borderless)
        } header: {
            Text("Profiles", comment: "Section header.")
        }
    }
}
