//
//  SettingsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/9/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var selectedTheme: UIUserInterfaceStyle = .unspecified
    @Published var showingClearWorkspaceAlert = false
    @Published var historyRentionDays: Int = 0
}
