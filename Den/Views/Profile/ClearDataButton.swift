//
//  ClearDataButton.swift
//  Den
//
//  Created by Garrett Johnson on 7/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ClearDataButton: View {
    @ObservedObject var profile: Profile

    var body: some View {
        Button {
            Task {
                await clearData()
                profile.objectWillChange.send()
            }
        } label: {
            Label {
                Text("Clear Data", comment: "Button label.")
            } icon: {
                Image(systemName: "clear")
            }
        }
        .accessibilityIdentifier("ClearData")
    }

    private func clearData() async {
        let container = PersistenceController.shared.container
        await container.performBackgroundTask { context in
            guard let profile = context.object(with: profile.objectID) as? Profile else {
                return
            }

            for feedData in profile.feedsArray.compactMap({ $0.feedData }) {
                context.delete(feedData)
            }

            for trend in profile.trends {
                context.delete(trend)
            }

            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
