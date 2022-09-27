//
//  SettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Binding var activeProfile: Profile?
    @Binding var uiStyle: UIUserInterfaceStyle

    var body: some View {
        Form {
            ProfilesSectionView(activeProfile: $activeProfile)
            FeedsSectionView(profile: activeProfile!)
            HistorySectionView(profile: activeProfile!)
            AppearanceSectionView(uiStyle: $uiStyle)
            ResetSectionView(activeProfile: $activeProfile)
            AboutSectionView()
        }
        .navigationTitle("Settings")
    }
}
