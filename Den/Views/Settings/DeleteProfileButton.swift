//
//  DeleteProfileButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeleteProfileButton: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profile: Profile
    
    var callback: () -> Void
    
    var body: some View {
        Button(role: .destructive) {
            Task {
                await delete()
                callback()
            }
        } label: {
            Label {
                Text("Delete", comment: "Button label.")
            } icon: {
                Image(systemName: "trash")
            }
        }
        .symbolRenderingMode(.multicolor)
        .accessibilityIdentifier("delete-profile-button")
    }
    
    private func delete() async {
        let container = PersistenceController.shared.container

        await container.performBackgroundTask { context in
            if let toDelete = context.object(with: profile.objectID) as? Profile {
                for feedData in toDelete.feedsArray.compactMap({$0.feedData}) {
                    context.delete(feedData)
                }
                context.delete(toDelete)
            }
            do {
                try context.save()
            } catch let error as NSError {
                CrashUtility.handleCriticalError(error)
            }
        }
    }
}
