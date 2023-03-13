//
//  ProfileSettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 1/7/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @Binding var contentSelection: ContentPanel?
    @Binding var activeProfile: Profile?
    @Binding var sceneProfileID: String?
    @Binding var appProfileID: String?

    @ObservedObject var profile: Profile

    @State var nameInput: String
    @State var tintSelection: String?
    @State private var showingDeleteAlert: Bool = false

    var body: some View {
        Form {
            nameSection
            tintSection
            ProfileSettingsHistorySectionView(
                profile: profile,
                historyRentionDays: profile.wrappedHistoryRetention
            )
            deleteSection
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    DispatchQueue.main.async {
                        sceneProfileID = profile.id?.uuidString
                        appProfileID = profile.id?.uuidString
                        activeProfile = profile
                        contentSelection = nil
                        profile.objectWillChange.send()
                    }
                } label: {
                    Label("Switch", systemImage: "arrow.left.arrow.right")
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(PlainToolbarButtonStyle())
                .disabled(isActive)
                .foregroundColor(isActive ? Color(.secondaryLabel) : nil)
                .accessibilityIdentifier("switch-to-profile-button")
            }
        }
        .navigationTitle("Profile Settings")
        .onDisappear {
            if profile.isDeleted { return }
            profile.wrappedName = nameInput

            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch let error {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        }
    }

    private var nameSection: some View {
        Section {
            TextField("Name", text: $nameInput)
                .modifier(FormRowModifier())
                .modifier(TitleTextFieldModifier())
        } header: {
            Text("Name").modifier(FormFirstHeaderModifier())
        }
    }

    private var tintSection: some View {
        Section {
            TintPickerView(tint: $tintSelection).onChange(of: tintSelection) { newValue in
                profile.tint = newValue
            }
        } header: {
            Text("Customization")
        }
    }

    private var isActive: Bool {
        profile.id?.uuidString == sceneProfileID
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
                sceneProfileID = nil
                appProfileID = nil
                activeProfile = nil
                contentSelection = nil
            } catch let error as NSError {
                CrashUtility.handleCriticalError(error)
            }
        }
    }
}
