//
//  ProfileSettings.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson
//

import SwiftUI

struct ProfileSettings: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    var body: some View {
        if profile.isDeleted || profile.managedObjectContext == nil {
            VStack {
                Spacer()
                ContentUnavailable {
                    Label {
                        Text("Profile Deleted", comment: "Content unavailable title.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
                Spacer()
            }
        } else {
            Form {
                Section {
                    TextField(text: $profile.wrappedName, prompt: profile.nameText) {
                        Text("Name", comment: "Text field label.")
                    }
                    .labelsHidden()
                    .onReceive(
                        profile.publisher(for: \.name)
                            .debounce(for: 1, scheduler: DispatchQueue.main)
                            .removeDuplicates()
                    ) { _ in
                        if viewContext.hasChanges {
                            do {
                                try viewContext.save()
                            } catch {
                                CrashUtility.handleCriticalError(error as NSError)
                            }
                        }
                    }
                } header: {
                    Text("Name", comment: "Section header.")
                }

                Section {
                    AccentColorSelector(selection: $profile.tintOption)
                        .onChange(of: profile.tint) {
                            do {
                                try viewContext.save()
                            } catch {
                                CrashUtility.handleCriticalError(error as NSError)
                            }
                        }
                } header: {
                    Text("Customization", comment: "Section header.")
                }

                ProfileHistorySection(
                    profile: profile,
                    historyRentionDays: profile.wrappedHistoryRetention
                )
                
                #if os(iOS)
                Section {
                    DeleteProfileButton(selection: .constant(profile))
                        .symbolRenderingMode(.multicolor)
                } header: {
                    Text("Management", comment: "Section header.")
                }
                #endif
            }
            .buttonStyle(.borderless)
            .formStyle(.grouped)
        }
    }
}
