//
//  PageConfigurationSheet.swift
//  Den
//
//  Created by Garrett Johnson on 6/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageConfigurationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if page.managedObjectContext == nil || page.isDeleted {
                    SplashNote(
                        Text("Page Deleted", comment: "Object removed message."),
                        icon: { Image(systemName: "xmark") }
                    )
                } else {
                    PageConfigurationForm(page: page)
                }
            }
            .navigationTitle(Text("Page Configuration", comment: "Navigation title."))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        Task {
                            viewContext.rollback()
                            page.objectWillChange.send()
                            dismiss()
                        }
                    } label: {
                        Text("Cancel", comment: "Button label.")
                    }
                    .accessibilityIdentifier("Cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Save", comment: "Button label.")
                    }
                    .accessibilityIdentifier("Save")
                }
            }
            .frame(minWidth: 370, minHeight: 500)
        }
    }
}
