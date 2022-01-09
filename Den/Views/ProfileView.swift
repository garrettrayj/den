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
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var themeManager: ThemeManager

    @State var showingIconPicker: Bool = false
    @State var showingDeleteAlert: Bool = false

    @ObservedObject var profile: Profile

    var body: some View {
        Form {
            nameSection
            deleteSection
        }
        .navigationTitle(profile.wrappedName)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    profileManager.activeProfile = profile
                    dismiss()
                } label: {
                    Label("Activate", systemImage: "power.circle")
                }
                .buttonStyle(NavigationBarButtonStyle())
                .disabled(profile == profileManager.activeProfile)
            }
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
                Label("Delete Profile", systemImage: "trash")
                    .symbolRenderingMode(profile == profileManager.activeProfile ? .monochrome : .multicolor)
            }
            .disabled(profile == profileManager.activeProfile)
            .modifier(FormRowModifier())
        } footer: {
            if profile == profileManager.activeProfile {
                Text("Active profile cannot be deleted.").padding(.vertical, 8)
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
