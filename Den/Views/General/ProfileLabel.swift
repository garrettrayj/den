//
//  ProfileLabel.swift
//  Den
//
//  Created by Garrett Johnson on 7/16/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ProfileLabel: View {
    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?

    var body: some View {
        Label {
            profile.nameText
        } icon: {
            Group {
                if profile.id?.uuidString == currentProfileID {
                    Image(systemName: "rhombus.fill")
                } else {
                    Image(systemName: "rhombus")
                }
            }.foregroundStyle(profile.tintColor ?? .primary)
        }
    }
}
