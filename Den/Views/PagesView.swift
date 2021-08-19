//
//  PagesView.swift
//  Den
//
//  Created by Garrett Johnson on 6/27/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PagesView: View {
    var body: some View {
        NavigationView {
            // Sidebar
            SidebarView()

            // Default view for detail area
            WelcomeView()
        }
    }
}
