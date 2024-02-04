//
//  ProfilePickerMenu.swift
//  Den
//
//  Created by Garrett Johnson on 10/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct ProfilePickerMenu: View {
    @ObservedObject var profile: Profile
    
    var profiles: [Profile]
    
    @Binding var currentProfileID: String?
    @Binding var lastProfileID: String?
    
    var body: some View {
        Menu {
            ProfilePicker(
                currentProfileID: $currentProfileID,
                lastProfileID: $lastProfileID,
                profiles: profiles
            )
            .pickerStyle(.inline)
        } label: {
            Label {
                profile.nameText
            } icon: {
                Image(systemName: "person.crop.circle").imageScale(.large)
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .menuOrder(.fixed)
        .accessibilityIdentifier("ProfileMenu")
    }
}
