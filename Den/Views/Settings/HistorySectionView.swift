//
//  HistorySectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/27/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct HistorySectionView: View {
    @Environment(\.persistentContainer) private var container
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @State var historyRentionDays: Int

    var historyCount: Int {
        profile.history?.count ?? 0
    }

    var body: some View {
        Section {
            Button {
                Task {
                    await resetHistory()
                }
                profile.objectWillChange.send()
            } label: {
                HStack {
                    Text("Clear History")
                    Spacer()
                    if historyCount > 0 {
                        if historyCount > 1 {
                            Text("\(historyCount) entries")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(historyCount) entry")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("No entries")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .disabled(historyCount == 0)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("clear-history-button")

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
            }.modifier(FormRowModifier())
        } header: {
            Text("History")
        } footer: {
            if historyRentionDays == 0 || historyRentionDays > 90 || historyCount > 100_000 {
                (
                    Text("\(Image(systemName: "exclamationmark.triangle")) ") +
                    Text("Retaining history for long periods may adversely affect performance")
                )
                .imageScale(.small)
            }
        }
        .onChange(of: historyRentionDays) { _ in
            profile.wrappedHistoryRetention = historyRentionDays
            if container.viewContext.hasChanges {
                do {
                    try container.viewContext.save()
                } catch let error {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        }
    }

    private func resetHistory() async {
        await container.performBackgroundTask { context in
            guard let profile = context.object(with: profile.objectID) as? Profile else { return }

            for history in profile.historyArray {
                context.delete(history)
            }

            for item in profile.previewItems.read() {
                item.read = false
            }

            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
