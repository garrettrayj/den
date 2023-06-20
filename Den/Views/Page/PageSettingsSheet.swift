//
//  PageSettingsSheet.swift
//  Den
//
//  Created by Garrett Johnson on 6/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    @State private var showingIconPicker: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if page.managedObjectContext == nil {
                    SplashNote(title: Text("Page Deleted", comment: "Object removed message."), symbol: "slash.circle")
                } else {
                    PageSettingsForm(page: page)
                }
            }
            .toolbar {
                #if os(macOS)
                ToolbarItem(placement: .confirmationAction) {
                    CloseButton(dismiss: dismiss)
                }
                ToolbarItem(placement: .destructiveAction) {
                    DeletePageButton(page: page, dismiss: dismiss)
                }
                #else
                ToolbarItem {
                    CloseButton(dismiss: dismiss)
                }
                ToolbarItem(placement: .topBarLeading) {
                    DeletePageButton(page: page, dismiss: dismiss).buttonStyle(.borderless)
                }
                #endif
            }
            .frame(minWidth: 400, minHeight: 480)
        }
    }
}
