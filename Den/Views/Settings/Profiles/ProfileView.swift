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

    @Binding var activeProfileID: String?
    @Binding var lastProfileID: String?

    @ObservedObject var profile: Profile

    @State var nameInput: String
    @State private var showingDeleteAlert: Bool = false

    var body: some View {
        Form {
            activateSection
            nameSection
            deleteSection
        }
        .navigationTitle("Profile")
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
            HStack {
                TextField("Name", text: $nameInput)
                    .modifier(TitleTextFieldModifier())
            }.modifier(FormRowModifier())
        } header: {
            Text("Name")
        }
    }

    private var isActive: Bool {
        profile.id?.uuidString == activeProfileID
    }

    private var activateSection: some View {
        Section {
            Button {
                activeProfileID = profile.id?.uuidString
                lastProfileID = profile.id?.uuidString
                dismiss()
            } label: {
                Label("Switch", systemImage: "arrow.left.arrow.right")
            }
            .disabled(isActive)
            .foregroundColor(isActive ? .secondary : nil)
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
            .disabled(isActive)
            .foregroundColor(isActive ? .secondary : .red)
            .modifier(FormRowModifier())
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
            Text("All profile content will be removed.")
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
            } catch let error as NSError {
                CrashUtility.handleCriticalError(error)
            }
        }
    }
}
