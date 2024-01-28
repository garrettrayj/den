//
//  ResetFeedsButton.swift
//  Den
//
//  Created by Garrett Johnson on 7/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct ResetFeedsButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Button {
            clearData()
        } label: {
            Label {
                Text("Erase Feed Data", comment: "Button label.")
            } icon: {
                Image(systemName: "clear")
            }
        }
        .accessibilityIdentifier("EraseData")
    }

    private func clearData() {
        guard let profiles = try? viewContext.fetch(Profile.fetchRequest()) as? [Profile] else {
            return
        }
        
        for profile in profiles {
            profile.feedsArray.compactMap { $0.feedData }.forEach { viewContext.delete($0) }
            RefreshedDateStorage.setRefreshed(profile, date: nil)
        }

        do {
            try viewContext.save()
            DispatchQueue.main.async {
                profiles.forEach { $0.objectWillChange.send() }
            }
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
