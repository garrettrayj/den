//
//  ResetFeedsButton.swift
//  Den
//
//  Created by Garrett Johnson on 7/20/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ResetFeedsButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Button {
            Task {
                await clearData()
            }
        } label: {
            Label {
                Text("Clear Feed Cache", comment: "Button label.")
            } icon: {
                Image(systemName: "clear")
            }
        }
        .accessibilityIdentifier("ClearData")
    }

    private func clearData() async {
        guard let profiles = try? viewContext.fetch(Profile.fetchRequest()) as? [Profile] else {
            return
        }
        
        for profile in profiles {
            for feedData in profile.feedsArray.compactMap({ $0.feedData }) {
                viewContext.delete(feedData)
            }
            
            for trend in profile.trends {
                viewContext.delete(trend)
            }
            
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
