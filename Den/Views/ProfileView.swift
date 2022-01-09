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

    @ObservedObject var profile: Profile

    var body: some View {
        Form {
            nameIconSection
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

    private var nameIconSection: some View {
        Section(header: Text("Name and Icon")) {
            HStack {
                TextField("Profile Name", text: $profile.wrappedName)
                    .modifier(TitleTextFieldModifier())
                HStack {
                    Image(systemName: profile.wrappedSymbol)
                        .foregroundColor(Color.accentColor)
                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                        .foregroundColor(.secondary)
                }
                .onTapGesture { showingIconPicker = true }
                .sheet(isPresented: $showingIconPicker) {
                    IconPickerView(symbol: $profile.wrappedSymbol)
                        .environment(\.colorScheme, colorScheme)
                }
            }.modifier(FormRowModifier())
        }.modifier(SectionHeaderModifier())
    }
}
