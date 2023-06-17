//
//  PageSettingsButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageSettingsButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page
    
    @State private var showSettings: Bool = false

    var body: some View {
        Button {
            showSettings = true
        } label: {
            Label {
                Text("Page Settings", comment: "Button label.")
            } icon: {
                Image(systemName: "wrench")
            }
        }
        .accessibilityIdentifier("page-settings-button")
        .sheet(
            isPresented: $showSettings,
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
            PageSettingsSheet(page: page)
        }
    }
}
