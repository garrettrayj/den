//
//  ProfilesSettingsTabDetail.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilesSettingsTabDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var profile: Profile
    
    @Binding var appProfileID: String?
    @Binding var activeProfile: Profile?
    
    let isActive: Bool
    let deleteCallback: () -> ()
    
    var body: some View {
        Form {
            List {
                TextField(text: $profile.wrappedName, prompt: profile.nameText) {
                    Text("Name")
                }
                .font(.title)
                .onChange(of: profile.wrappedName) { _ in
                    if viewContext.hasChanges {
                        do {
                            try viewContext.save()
                        } catch let error {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    }
                }
                
                TintPicker(tintSelection: $profile.tintOption)
                    .onChange(of: profile.tint) { _ in
                        if viewContext.hasChanges {
                            do {
                                try viewContext.save()
                            } catch let error {
                                CrashUtility.handleCriticalError(error as NSError)
                            }
                        }
                    }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    DeleteProfileButton(profile: profile, callback: deleteCallback)
                        .disabled(profile == activeProfile)
                    Spacer()
                    Button {
                        DispatchQueue.main.async {
                            appProfileID = profile.id?.uuidString
                            activeProfile = profile
                            profile.objectWillChange.send()
                        }
                    } label: {
                        Label {
                            Text("Switch", comment: "Button label.")
                        } icon: {
                            Image(systemName: "arrow.left.arrow.right")
                        }
                    }
                    .disabled(profile == activeProfile)
                    .accessibilityIdentifier("switch-profile-button")
                }
                .padding(8)
            }
        }
    }
}
