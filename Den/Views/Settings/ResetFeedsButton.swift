//
//  ResetFeedsButton.swift
//  Den
//
//  Created by Garrett Johnson on 7/20/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ResetFeedsButton: View {
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
        let container = PersistenceController.shared.container
        
        await container.performBackgroundTask { context in
            guard let profiles = try? context.fetch(Profile.fetchRequest()) as? [Profile] else {
                return
            }
            
            for profile in profiles {
                for feedData in profile.feedsArray.compactMap({ $0.feedData }) {
                    context.delete(feedData)
                }
                
                for trend in profile.trends {
                    context.delete(trend)
                }
            }

            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
