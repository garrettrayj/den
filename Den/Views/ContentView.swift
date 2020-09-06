//
//  ContentView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var screenManager: ScreenManager
    
    @FetchRequest(entity: Page.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)])
    var pages: FetchedResults<Page>
    
    var body: some View {
        NavigationView {
            WorkspaceView(pages: pages)
            WelcomeView(pages: pages)
        }.onAppear {
            #if targetEnvironment(macCatalyst)
            if self.screenManager.activePage == nil {
                self.screenManager.activePage = self.pages.first?.id?.uuidString
            }
            #endif
        }
    }
}
