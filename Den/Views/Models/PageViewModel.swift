//
//  PageViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

final class PageViewModel: ObservableObject, Identifiable {
    @Published var page: Page
    @Published var refreshState: RefreshState = .waiting
    @Published var refreshFractionCompleted: CGFloat = 0
    @Published var progress = Progress(totalUnitCount: 0)

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager

    init(page: Page, viewContext: NSManagedObjectContext, crashManager: CrashManager) {
        self.page = page
        self.viewContext = viewContext
        self.crashManager = crashManager

        progress
            .publisher(for: \.fractionCompleted)
            .receive(on: RunLoop.main)
            .map { fractionCompleted in
                CGFloat(fractionCompleted)
            }
            .assign(to: &$refreshFractionCompleted)
    }
}
