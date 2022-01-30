//
//  StartListView.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct StartListView: View {
    @ObservedObject var viewModel: ProfileViewModel

    @Binding var showingSettings: Bool

    var body: some View {
        List {
            Section {
                Button(action: viewModel.createPage) {
                    Label("Create a Blank Page", systemImage: "plus")
                }.modifier(StartRowModifier())

                Button(action: viewModel.loadDemo) {
                    Label("Load Demo Feeds", systemImage: "wand.and.stars")
                }.modifier(StartRowModifier())
            } header: {
                Text("Get Started")
            } footer: {
                Text("or import feeds in settings")
                #if targetEnvironment(macCatalyst)
                    .font(.system(size: 13)).padding(.vertical, 12)
                #endif
            }
            .lineLimit(1)
            .modifier(SectionHeaderModifier())
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear").labelStyle(.titleAndIcon)
                }.buttonStyle(ToolbarButtonStyle())
            }
        }
    }
}
