//
//  HistorySectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct HistorySectionView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var activeProfile: Profile?

    @State var historyRentionDays: Int = 0
    @State var showingClearHistoryAlert = false

    var body: some View {
        Section(header: Text("History")) {
            NavigationLink(value: DetailPanel.history) {
                Text("Log")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("view-history-button")

            historyRetentionPicker.modifier(FormRowModifier())

            Button(role: .destructive) {
                showingClearHistoryAlert = true
            } label: {
                Text("Erase")
            }
            .modifier(FormRowModifier())
            .alert("Erase History?", isPresented: $showingClearHistoryAlert, actions: {
                Button("Cancel", role: .cancel) { }.accessibilityIdentifier("reset-cancel-button")
                Button("Erase", role: .destructive) {
                    eraseHistory()
                }.accessibilityIdentifier("reset-confirm-button")
            }, message: {
                Text("Memory of read items will be cleared for the current profile.")
            })
            .accessibilityIdentifier("clear-history-button")
        }
    }

    private var historyRetentionPicker: some View {
        Picker(selection: $historyRentionDays) {
            Text("Forever").tag(0 as Int)
            Text("One year").tag(365 as Int)
            Text("Six months").tag(182 as Int)
            Text("Three months").tag(90 as Int)
            Text("One month").tag(30 as Int)
            Text("Two weeks").tag(14 as Int)
            Text("One week").tag(7 as Int)
        } label: {
            Text("Keep")
        }.onAppear {
            historyRentionDays = activeProfile?.wrappedHistoryRetention ?? 0
        }.onChange(of: historyRentionDays) { newValue in
            if activeProfile?.wrappedHistoryRetention != newValue {
                activeProfile?.wrappedHistoryRetention = newValue
                do {
                    try viewContext.save()
                } catch let error as NSError {
                    CrashManager.handleCriticalError(error)
                }
            }
        }
    }

    private func eraseHistory() {
        activeProfile?.historyArray.forEach { history in
            self.viewContext.delete(history)
        }

        activeProfile?.previewItems.forEach { item in
            item.read = false
        }

        do {
            try viewContext.save()
            activeProfile?.objectWillChange.send()
            activeProfile?.pagesArray.forEach { page in
                NotificationCenter.default.post(name: .pageRefreshed, object: page.objectID)
            }
        } catch let error as NSError {
            CrashManager.handleCriticalError(error)
            return
        }
    }
}
