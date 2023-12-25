//
//  ProfileHistorySection.swift
//  Den
//
//  Created by Garrett Johnson on 11/27/22.
//  Copyright © 2022 Garrett Johnson
//

import CoreData
import SwiftUI

struct ProfileHistorySection: View {
    @ObservedObject var profile: Profile

    var body: some View {
        Section {
            Button {
                Task {
                    await clear()
                }
            } label: {
                Label {
                    Text("Clear History", comment: "Button label.")
                } icon: {
                    Image(systemName: "clear")
                }
            }
            .disabled(profile.history?.count ?? 0 == 0)
            .accessibilityIdentifier("ClearHistory")
        } header: {
            Text("History", comment: "Section header.")
        }
    }

    private func clear() async {
        let container = PersistenceController.shared.container

        await container.performBackgroundTask { context in
            guard let profile = context.object(with: profile.objectID) as? Profile else { return }

            for history in profile.historyArray {
                context.delete(history)
            }

            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(
                format: "feedData.id IN %@",
                profile.pagesArray.flatMap({ page in
                    page.feedsArray.compactMap { feed in
                        feed.feedData?.id
                    }
                })
            )

            if let results = try? context.fetch(request) {
                for item in results {
                    item.read = false
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
