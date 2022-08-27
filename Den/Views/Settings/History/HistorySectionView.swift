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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var syncManager: SyncManager

    let profile: Profile

    @State var historyRentionDays: Int = 0
    @State var showingClearHistoryAlert = false

    var body: some View {
        Section(header: Text("History")) {
            NavigationLink(
                destination: HistoryView(profile: profile)
            ) {
                Label("Viewed Items", systemImage: "clock")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("view-history-button")

            #if targetEnvironment(macCatalyst)
            HStack {
                historyRetentionLabel
                Spacer()
                historyRetentionPicker
                    .frame(width: 200)
            }.modifier(FormRowModifier())
            #else
            historyRetentionPicker
            #endif

            Button(role: .destructive) {
                showingClearHistoryAlert = true
            } label: {
                Label("Erase History", systemImage: "hourglass.bottomhalf.filled")
                    .lineLimit(1)
                    .foregroundColor(.red)
            }
            .modifier(FormRowModifier())
            .alert("Erase History?", isPresented: $showingClearHistoryAlert, actions: {
                Button("Cancel", role: .cancel) { }.accessibilityIdentifier("reset-cancel-button")
                Button("Erase", role: .destructive) {
                    eraseHistory()
                }.accessibilityIdentifier("reset-confirm-button")
            }, message: {
                Text("Memory of items viewed or marked read will be cleared.")
            })
            .accessibilityIdentifier("clear-history-button")
        }
        .modifier(SectionHeaderModifier())
        .onChange(of: historyRentionDays) { _ in
            profile.wrappedHistoryRetention = historyRentionDays
            saveProfile()
        }
    }

    private var historyRetentionLabel: some View {
        Label("Keep History", systemImage: "clock.arrow.2.circlepath").lineLimit(1)
    }

    private var historyRetentionPicker: some View {
        Picker(selection: $historyRentionDays) {
            Text("Forever").tag(0 as Int)
            Text("One Year").tag(365 as Int)
            Text("Six Months").tag(182 as Int)
            Text("Three Months").tag(90 as Int)
            Text("One Month").tag(30 as Int)
            Text("Two Weeks").tag(14 as Int)
            Text("One Week").tag(7 as Int)
        } label: {
            historyRetentionLabel
        }
    }

    private func eraseHistory() {
        profile.historyArray.forEach { history in
            self.viewContext.delete(history)
        }
        do {
            try viewContext.save()
        } catch let error as NSError {
            CrashManager.handleCriticalError(error)
            return
        }

        syncManager.updateLocalHistory()

        profile.objectWillChange.send()
        profile.pagesArray.forEach { page in
            NotificationCenter.default.post(name: .pageRefreshed, object: page.objectID)
        }
    }

    private func saveProfile() {
        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                CrashManager.handleCriticalError(error)
            }
        }
    }
}
