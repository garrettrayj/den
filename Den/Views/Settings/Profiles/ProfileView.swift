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

    @Binding var activeProfile: Profile?

    @ObservedObject var profile: Profile

    @State var nameInput: String 
    @State private var showingDeleteAlert: Bool = false

    var body: some View {
        Form {
            nameSection
            activateSection
            deleteSection
        }
        .navigationTitle("Profile")
        .onDisappear {
            profile.wrappedName = nameInput
            save()
        }
    }

    private var nameSection: some View {
        Section(header: Text("Name").modifier(FormFirstHeaderModifier())) {
            HStack {
                TextField("Name", text: $nameInput)
                    .modifier(TitleTextFieldModifier())
            }.modifier(FormRowModifier())
        }
    }

    private var activateSection: some View {
        Section {
            Button {
                activeProfile = ProfileManager.activateProfile(profile)
                dismiss()
            } label: {
                Label("Switch", systemImage: "arrow.left.arrow.right")
            }
            .disabled(profile == activeProfile)
            .foregroundColor(profile == activeProfile ? .secondary : nil)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("activate-profile-button")
        }
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(profile == activeProfile)
            .foregroundColor(profile == activeProfile ? .secondary : .red)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("delete-profile-button")
        }.alert("Delete Profile?", isPresented: $showingDeleteAlert, actions: {
            Button("Cancel", role: .cancel) { }.accessibilityIdentifier("delete-profile-cancel-button")
            Button("Delete", role: .destructive) {
                dismiss()
                viewContext.delete(profile)
                do {
                    try viewContext.save()
                } catch let error as NSError {
                    CrashManager.handleCriticalError(error)
                }
            }.accessibilityIdentifier("delete-profile-confirm-button")
        }, message: {
            Text("All profile content will be removed.")
        })
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                profile.objectWillChange.send()
            } catch {
                CrashManager.handleCriticalError(error as NSError)
            }
        }
    }
}
