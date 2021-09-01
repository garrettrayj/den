//
//  PagesView.swift
//  Den
//
//  Created by Garrett Johnson on 6/27/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PagesView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var refreshManager: RefreshManager

    var body: some View {
        NavigationView {
            SidebarView(
                viewModel: PagesViewModel(
                    profileManager: profileManager,
                    viewContext: viewContext,
                    crashManager: crashManager,
                    refreshManager: refreshManager
                )
            )

            // Default view for detail area
            WelcomeView(profile: profileManager.activeProfile)
        }

    }
}
