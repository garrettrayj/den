//
//  ProfilesView.swift
//  Den
//
//  Created by Garrett Johnson on 1/7/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ProfilesView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var crashManager: CrashManager

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    @State var showingCannotDeleteAlert: Bool = false

    var body: some View {
        List {
            Section {
                ForEach(profiles) { profile in
                    NavigationLink {
                        ProfileView(profile: profile)
                    } label: {
                        if profile == profileManager.activeProfile {
                            HStack {
                                Label(profile.wrappedName, systemImage: profile.wrappedSymbol)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                                    .font(.body.weight(.bold))
                            }
                        } else {
                            Label(profile.wrappedName, systemImage: profile.wrappedSymbol)
                        }
                    }.modifier(FormRowModifier())
                }
                .onDelete(perform: deleteProfile)
            } footer: {
                Text("""
Use profiles to create separate collections of pages. \
Visited items, history settings, and feed settings are distinct for each profile.
""")
                    .padding(.vertical, 8)
            }

        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: profileManager.addProfile) {
                    Label("New Profile", systemImage: "plus")
                }.buttonStyle(NavigationBarButtonStyle())
            }
        }
        .navigationTitle("Profiles")
        .alert(
            "The currently active profile may not be deleted",
            isPresented: $showingCannotDeleteAlert,
            actions: {
                Button("Dismiss", role: .cancel) { }
            }
        )
    }

    func deleteProfile(indices: IndexSet) {
        for index in indices where profiles[index] == profileManager.activeProfile {
            showingCannotDeleteAlert = true
            return
        }

        indices.forEach {
            viewContext.delete(profiles[$0])
        }

        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }
}
