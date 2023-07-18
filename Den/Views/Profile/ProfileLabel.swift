//
//  ProfileLabel.swift
//  Den
//
//  Created by Garrett Johnson on 7/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileLabel: View {
    @ObservedObject var profile: Profile
    
    @Binding var currentProfileID: String?
    
    var body: some View {
        Label {
            profile.nameText
        } icon: {
            if profile.id?.uuidString == currentProfileID {
                Image(systemName: "rhombus.fill").foregroundColor(profile.tintColor)
            } else {
                Image(systemName: "rhombus").foregroundColor(profile.tintColor)
            }
        }
    }
}
