//
//  FeedSettingsButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedSettingsButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed
    
    @State private var showingSettings: Bool = false

    var body: some View {
        
        Button {
            showingSettings = true
        } label: {
            Label {
                Text("Feed Settings", comment: "Button label.")
            } icon: {
                Image(systemName: "wrench")
            }
        }
        .buttonStyle(ToolbarButtonStyle())
        .accessibilityIdentifier("feed-settings-button")
        .sheet(
            isPresented: $showingSettings,
            onDismiss: {
                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        ) {
            FeedSettingsSheet(feed: feed)
        }
    }
}

