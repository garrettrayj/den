//
//  ProfileView.swift
//  Den
//
//  Created by Garrett Johnson on 1/7/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var profileManager: ProfileManager

    @State private var showingDeleteAlert: Bool = false

    @ObservedObject var profile: Profile

    var body: some View {
        Form {
            nameSection
            activateDeleteSection
        }
        .navigationTitle("Profile Settings")
        .onDisappear {
            NotificationCenter.default.post(name: .profileRefreshed, object: profile.objectID)
        }
    }

    private var nameSection: some View {
        Section(header: Text("Name")) {
            HStack {
                TextField("Name", text: $profile.wrappedName)
                    .modifier(TitleTextFieldModifier())
            }.modifier(FormRowModifier())
        }.modifier(SectionHeaderModifier())
    }

    private var activateDeleteSection: some View {
        Section {
            Button {
                profileManager.activateProfile(profile)
                dismiss()
            } label: {
                Label("Switch", systemImage: "power.circle")
            }
            .disabled(profile == profileManager.activeProfile)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("activate-profile-button")

            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .symbolRenderingMode(profile == profileManager.activeProfile ? .monochrome : .multicolor)
            }
            .disabled(profile == profileManager.activeProfile)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("delete-profile-button")
        } footer: {
            if profile == profileManager.activeProfile {
                Text("Active profile cannot be deleted").padding(.vertical, 8)
            }
        }.alert("Delete Profile?", isPresented: $showingDeleteAlert, actions: {
            Button("Cancel", role: .cancel) { }.accessibilityIdentifier("delete-profile-cancel-button")
            Button("Delete", role: .destructive) {
                viewContext.delete(profile)
                do {
                    try viewContext.save()
                    dismiss()
                } catch let error as NSError {
                    crashManager.handleCriticalError(error)
                }
            }.accessibilityIdentifier("delete-profile-confirm-button")
        }, message: {
            Text("Pages, feeds, and history will be removed. This action cannot be undone.")
        })
    }
}
