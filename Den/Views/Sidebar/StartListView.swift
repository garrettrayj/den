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
            Section(content: {
                Button(action: viewModel.createPage) {
                    Label("Create a blank page", systemImage: "plus")
                }.modifier(StartRowModifier())

                Button(action: viewModel.loadDemo) {
                    Label("Load demo feeds", systemImage: "wand.and.stars")
                }.modifier(StartRowModifier())
            }, header: {
                Text("Get started")
            }, footer: {
                Text("or import feeds in settings")
            })
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear").labelStyle(.titleAndIcon)
                }
            }
        }
    }
}
