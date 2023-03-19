//
//  ProfileSettingsHistorySectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/27/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct ProfileSettingsHistorySectionView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @State var historyRentionDays: Int

    var historyCount: Int {
        profile.history?.count ?? 0
    }

    var body: some View {
        Section {
            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Keep History").modifier(FormRowModifier())
                Spacer()
                Picker(selection: $historyRentionDays) {
                    Text("Forever").tag(0 as Int)
                    Text("One Year").tag(365 as Int)
                    Text("Six Months").tag(182 as Int)
                    Text("Three Months").tag(90 as Int)
                    Text("One Month").tag(30 as Int)
                    Text("Two Weeks").tag(14 as Int)
                    Text("One Week").tag(7 as Int)
                } label: {
                    Text("Keep History")
                }
                .labelsHidden()
                .scaledToFit()
            }
            #else
            Picker(selection: $historyRentionDays) {
                Text("Forever").tag(0 as Int)
                Text("One Year").tag(365 as Int)
                Text("Six Months").tag(182 as Int)
                Text("Three Months").tag(90 as Int)
                Text("One Month").tag(30 as Int)
                Text("Two Weeks").tag(14 as Int)
                Text("One Week").tag(7 as Int)
            } label: {
                Text("Keep History").modifier(FormRowModifier())
            }
            #endif

            Button {
                Task {
                    await resetHistory()
                }
                profile.objectWillChange.send()
            } label: {
                HStack {
                    Text("Clear History")
                    Spacer()
                    Group {
                        if historyCount > 0 {
                            if historyCount > 1 {
                                Text("\(historyCount) entries")
                            } else {
                                Text("\(historyCount) entry")
                            }
                        } else {
                            Text("No entries")
                        }
                    }
                    .font(.callout)
                    .foregroundColor(Color(.secondaryLabel))
                }
            }
            .disabled(historyCount == 0)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("clear-history-button")
        } header: {
            Text("History")
        } footer: {
            if historyRentionDays == 0 || historyRentionDays > 90 || historyCount > 100_000 {
                (
                    Text("\(Image(systemName: "exclamationmark.triangle")) ") +
                    Text("Retaining history for long periods may adversely affect performance.")
                )
                .imageScale(.small)
            }
        }
        .onChange(of: historyRentionDays) { _ in
            profile.wrappedHistoryRetention = historyRentionDays
            do {
                try viewContext.save()
            } catch let error {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }

    private func resetHistory() async {
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
