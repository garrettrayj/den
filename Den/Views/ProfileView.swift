//
//  ProfileView.swift
//  Den
//
//  Created by Garrett Johnson on 1/7/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var showingIconPicker: Bool = false
    @State private var showingDeleteAlert: Bool = false

    @ObservedObject var profile: Profile

    var body: some View {
        Form {
            nameSection
            deleteSection
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    profileManager.activateProfile(profile)
                    dismiss()
                } label: {
                    Label("Activate", systemImage: "power.circle")
                }
                .buttonStyle(ActivateButtonStyle())
                .disabled(profile == profileManager.activeProfile)
            }
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

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .symbolRenderingMode(profile == profileManager.activeProfile ? .monochrome : .multicolor)
            }
            .disabled(profile == profileManager.activeProfile)
            .modifier(FormRowModifier())
        } footer: {
            if profile == profileManager.activeProfile {
                Text("Cannot delete active profile").padding(.vertical, 8)
            }
        }.alert("Delete Profile?", isPresented: $showingDeleteAlert, actions: {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewContext.delete(profile)
                do {
                    try viewContext.save()
                    dismiss()
                } catch let error as NSError {
                    crashManager.handleCriticalError(error)
                }
            }
        }, message: {
            Text("Pages, feeds, and history will be removed. This action cannot be undone.")
        })
    }
}
