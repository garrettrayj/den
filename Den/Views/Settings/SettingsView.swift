//
//  SettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            ProfilesSectionView()
            FeedsSectionView()
            HistorySectionView()
            AppearanceSectionView()
            ResetSectionView()
            AboutSectionView()
        }
        .navigationTitle("Settings")
    }
}
