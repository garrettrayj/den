//
//  ProfileSettings.swift
//  Den
//
//  Created by Garrett Johnson on 1/7/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileSettings: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?

    @State private var showingDeleteAlert: Bool = false

    @State var tintSelection: String?

    var body: some View {
        Form {
            nameSection
            tintSection
            FeedUtilitiesSection(profile: profile)
            HistorySettingsSection(profile: profile, historyRentionDays: profile.wrappedHistoryRetention)
            deleteSection
        }
        .onDisappear {
            if profile.isDeleted { return }
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch let error {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    DispatchQueue.main.async {
                        appProfileID = profile.id?.uuidString
                        activeProfile = profile
                        profile.objectWillChange.send()
                        dismiss()
                    }
                } label: {
                    Label("Switch", systemImage: "arrow.left.arrow.right")
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(PlainToolbarButtonStyle())
                .disabled(profile == activeProfile)
                .accessibilityIdentifier("switch-to-profile-button")
            }
        }
        .navigationTitle("Profile Settings")
    }

    private var nameSection: some View {
        Section {
            TextField("Name", text: $profile.wrappedName)
                .modifier(FormRowModifier())
                .modifier(TitleTextFieldModifier())
        } header: {
            Text("Name").modifier(FirstFormHeaderModifier())
        }
        .modifier(ListRowModifier())
    }

    private var tintSection: some View {
        Section {
            TintPicker(tint: $tintSelection).onChange(of: tintSelection) { newValue in
                profile.tint = newValue
            }
        } header: {
            Text("Customization")
        }
        .modifier(ListRowModifier())
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .symbolRenderingMode(.multicolor)
                    .modifier(FormRowModifier())
            }
            .accessibilityIdentifier("delete-profile-button")
        }.alert("Delete Profile?", isPresented: $showingDeleteAlert, actions: {
            Button("Cancel", role: .cancel) { }.accessibilityIdentifier("delete-profile-cancel-button")
            Button("Delete", role: .destructive) {
                Task {
                    await delete()
                }
                dismiss()
            }.accessibilityIdentifier("delete-profile-confirm-button")
        }, message: {
            Text("All content within will be removed.")
        })
        .modifier(ListRowModifier())
    }

    private func delete() async {
        let container = PersistenceController.shared.container

        await container.performBackgroundTask { context in
            if let toDelete = context.object(with: profile.objectID) as? Profile {
                for feedData in toDelete.feedsArray.compactMap({$0.feedData}) {
                    context.delete(feedData)
                }
                context.delete(toDelete)
            }

            do {
                try context.save()
                appProfileID = nil
                activeProfile = nil
                dismiss()
            } catch let error as NSError {
                CrashUtility.handleCriticalError(error)
            }
        }
    }
}
