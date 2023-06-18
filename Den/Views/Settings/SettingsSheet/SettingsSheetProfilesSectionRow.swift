//
//  SettingsSheetProfilesSectionRow.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsSheetProfilesSectionRow: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var profile: Profile
    
    @Binding var appProfileID: String?
    @Binding var activeProfile: Profile?
    
    @State private var showingDetail: Bool = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            Label {
                profile.nameText
            } icon: {
                Image(systemName: profile == activeProfile ? "hexagon.fill" : "hexagon")
                    .foregroundColor(profile.tintColor)
            }
        }
        .navigationDestination(isPresented: $showingDetail) {
            SettingsSheetProfileDetail(
                profile: profile,
                appProfileID: $appProfileID,
                activeProfile: $activeProfile
            )
        }
    }
}
