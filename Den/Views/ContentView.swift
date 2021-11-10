//
//  ContentView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @StateObject var viewModel: ContentViewModel

    var body: some View {
        if viewModel.showingCrashMessage == true {
            CrashMessageView()
        } else {
            navigationView
        }
    }

    private var navigationView: some View {
        NavigationView {
            SidebarView(viewModel: viewModel)

            // Default view for detail area
            WelcomeView(contentViewModel: viewModel)
        }
        .modifier(MacButtonStyleModifier())
        .sheet(isPresented: $viewModel.showingAddSubscription) {
            SubscribeView(viewModel: SubscribeViewModel(viewContext: viewContext, contentViewModel: viewModel))
            .environment(\.colorScheme, colorScheme)
        }
    }
}
