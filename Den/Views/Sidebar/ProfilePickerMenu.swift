//
//  ProfilePickerMenu.swift
//  Den
//
//  Created by Garrett Johnson on 10/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilePickerMenu: View {
    @ObservedObject var profile: Profile
    
    @Binding var currentProfileID: String?
    
    var body: some View {
        Menu {
            ProfilePicker(currentProfileID: $currentProfileID).pickerStyle(.inline)
        } label: {
            Label {
                profile.nameText
            } icon: {
                Image(systemName: "person").imageScale(.large)
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .menuOrder(.fixed)
        .accessibilityIdentifier("ProfileMenu")
    }
}
