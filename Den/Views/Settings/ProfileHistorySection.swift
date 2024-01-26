//
//  ProfileHistorySection.swift
//  Den
//
//  Created by Garrett Johnson on 11/27/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct ProfileHistorySection: View {
    @ObservedObject var profile: Profile

    private var historyCount: Int {
        profile.history?.count ?? 0
    }

    var body: some View {
        Section {
            Button {
                Task {
                    await clear()
                }
            } label: {
                Label {
                    HStack {
                        Text("Clear", comment: "Button label.")
                        Spacer()
                        Group {
                            if historyCount == 1 {
                                Text("1 Record", comment: "History count (singular).")
                            } else {
                                Text("\(historyCount) Records", comment: "History count (plural).")
                            }
                        }
                    }
                } icon: {
                    Image(systemName: "clear")
                }
            }
            .disabled(historyCount == 0)
            .accessibilityIdentifier("ClearHistory")
        } header: {
            Text("Read History", comment: "Profile settings section header.")
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
