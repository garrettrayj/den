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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var safariManager: LinkManager
    
    var body: some View {
        NavigationView {
            // Sidebar
            SidebarView()
            
            // Default view for detail area
            WelcomeView()
        }
        
    }
}
