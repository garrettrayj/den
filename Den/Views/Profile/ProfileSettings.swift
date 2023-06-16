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
            HistorySettingsSection(
                profile: profile,
                historyRentionDays: profile.wrappedHistoryRetention
            )
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
            #if os(iOS)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    DispatchQueue.main.async {
                        appProfileID = profile.id?.uuidString
                        activeProfile = profile
                        profile.objectWillChange.send()
                        dismiss()
                    }
                } label: {
                    Label {
                        Text("Switch", comment: "Button label.")
                    } icon: {
                        Image(systemName: "arrow.left.arrow.right")
                    }
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(PlainToolbarButtonStyle())
                .disabled(profile == activeProfile)
                .accessibilityIdentifier("switch-to-profile-button")
            }
            #endif
        }
        .navigationTitle(Text("Profile Settings", comment: "Navigation title."))
    }

    private var nameSection: some View {
        Section {
            TextField(text: $profile.wrappedName, prompt: Text("Untitled", comment: "Text field prompt.")) {
                Text("Name", comment: "Text field label.")
            }
            .modifier(FormRowModifier())
            .modifier(TitleTextFieldModifier())
        } header: {
            Text("Name", comment: "Profile settings section header.").modifier(FirstFormHeaderModifier())
        }
        .modifier(ListRowModifier())
    }

    private var tintSection: some View {
        Section {
            TintPicker(tint: $tintSelection).onChange(of: tintSelection) { newValue in
                profile.tint = newValue
            }
        } header: {
            Text("Customization", comment: "Profile settings section header.")
        }
        .modifier(ListRowModifier())
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label {
                    Text("Delete", comment: "Button label.")
                } icon: {
                    Image(systemName: "trash")
                }
                .symbolRenderingMode(.multicolor)
                .modifier(FormRowModifier())
            }
            .accessibilityIdentifier("delete-profile-button")
        }.alert(
            Text("Delete Profile?", comment: "Alert title."),
            isPresented: $showingDeleteAlert,
            actions: {
                Button(role: .cancel) {
                    // Pass
                } label: {
                    Text("Cancel", comment: "Button label.")
                }
                .accessibilityIdentifier("delete-profile-cancel-button")

                Button(role: .destructive) {
                    Task {
                        await delete()
                    }
                    dismiss()
                } label: {
                    Text("Delete", comment: "Button label.")
                }
                .accessibilityIdentifier("delete-profile-confirm-button")
            },
            message: {
                Text(
                    "All profile content (pages, feeds, history, etc.) will be removed.",
                    comment: "Alert message."
                )
            }
        )
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
