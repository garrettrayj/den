//
//  DeleteProfileButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct DeleteProfileButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var selection: Profile?
    
    @State private var showingAlert = false
    
    var body: some View {
        Button(role: .destructive) {
            showingAlert = true
        } label: {
            Label {
                Text("Delete Profile", comment: "Button label.")
            } icon: {
                #if os(macOS)
                Image(systemName: "minus")
                #else
                Image(systemName: "person.badge.minus")
                #endif
            }
        }
        .alert(
            Text("Delete Profile?", comment: "Alert title."),
            isPresented: $showingAlert,
            actions: {
                Button(role: .cancel) {
                    // Pass
                } label: {
                    Text("Cancel", comment: "Button label.")
                }
                .accessibilityIdentifier("CancelDeleteProfile")

                Button(role: .destructive) {
                    delete()
                } label: {
                    Text("Delete", comment: "Button label.")
                }
                .accessibilityIdentifier("ConfirmDeleteProfile")
            },
            message: {
                Text(
                    "All profile content (pages, feeds, history, etc.) will be removed.",
                    comment: "Alert message."
                )
            }
        )
        .accessibilityIdentifier("DeleteProfile")
    }
    
    private func delete() {
        guard let profile = selection else { return }
        
        for feedData in profile.feedsArray.compactMap({$0.feedData}) {
            viewContext.delete(feedData)
        }
        for trend in profile.trends {
            viewContext.delete(trend)
        }
        viewContext.delete(profile)

        do {
            try viewContext.save()
            selection = nil
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
