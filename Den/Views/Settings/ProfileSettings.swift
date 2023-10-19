//
//  ProfileSettings.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileSettings: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @State private var showingAlert = false

    var body: some View {
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

            Section {
                Button(role: .destructive) {
                    showingAlert = true
                } label: {
                    Label {
                        Text("Delete Profile", comment: "Button label.")
                    } icon: {
                        Image(systemName: "person.crop.circle.badge.minus")
                    }
                }
                .alert(
                    Text("Delete Profile?", comment: "Alert title."),
                    isPresented: $showingAlert,
                    actions: {
                        Button(role: .cancel) {
                            // Pass
                        } label: {
                            Text("Cancel", comment: "Button label.")
                        }
                        .accessibilityIdentifier("CancelDeleteProfile")

                        Button(role: .destructive) {
                            delete()
                            dismiss()
                        } label: {
                            Text("Delete", comment: "Button label.")
                        }
                        .accessibilityIdentifier("ConfirmDeleteProfile")
                    },
                    message: {
                        Text(
                            "All profile content (pages, feeds, history, etc.) will be removed.",
                            comment: "Alert message."
                        )
                    }
                )
                .symbolRenderingMode(.multicolor)
                .accessibilityIdentifier("DeleteProfile")
            } header: {
                Text("Danger Zone", comment: "Section header.")
            }
        }
        .buttonStyle(.borderless)
        .formStyle(.grouped)
        .navigationTitle(profile.nameText)
    }

    private func delete() {
        for feedData in profile.feedsArray.compactMap({$0.feedData}) {
            viewContext.delete(feedData)
        }
        for trend in profile.trends {
            viewContext.delete(trend)
        }
        viewContext.delete(profile)

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
