//
//  TrendsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI
import OSLog
import NaturalLanguage

class TrendsViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager
    let profile: Profile

    @Published var analyzing: Bool = true
    @Published var trends: [Trend] = []

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, profile: Profile) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.profile = profile
    }
}
