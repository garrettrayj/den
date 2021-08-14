//
//  FeedWidgetSettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedWidgetSettingsView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var feed: Feed

    var body: some View {
        NavigationView {
            FeedSettingsFormView(
                feed: feed,
                onDelete: close,
                onMove: close
            )
            .navigationTitle("Feed Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button(action: close) { Text("Close") }.buttonStyle(ActionButtonStyle())
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func close() {
        presentation.wrappedValue.dismiss()
    }
}
