//
//  SettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var viewModel: SettingsViewModel

    @AppStorage("UIStyle") private var uiStyle = UIUserInterfaceStyle.unspecified

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    @State var showingResetAlert = false
    @State var showingClearHistoryAlert = false
    @State var historyRentionDays: Int = 0

    var body: some View {
        Form {
            profilesSection
            feedsSection
            historySection
            appearanceSection
            dataSection
            aboutSection
        }
        .navigationTitle("Settings")
    }

    private var profilesSection: some View {
        Section {
            ForEach(profiles) { profile in
                NavigationLink {
                    ProfileView(profile: profile)
                } label: {
                    Label(
                        profile.displayName,
                        systemImage: profile == profileManager.activeProfile ? "hexagon.fill" : "hexagon"
                    )
                }
                .modifier(FormRowModifier())
                .accessibilityIdentifier("profile-button")
            }

            Button(action: profileManager.addProfile) {
                Label("Add Profile", systemImage: "plus")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("add-profile-button")
        } header: {
            Text("Profiles")
        }.modifier(SectionHeaderModifier())
    }

    private var appearanceSection: some View {
        Section(header: Text("Appearance")) {
            #if targetEnvironment(macCatalyst)
            HStack {
                themeSelectionLabel
                Spacer()
                themeSelectionPicker
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                    .modifier(FormRowModifier())
            }
            #else
            themeSelectionPicker.modifier(FormRowModifier())
            #endif

        }
        .modifier(SectionHeaderModifier())
        .onChange(of: uiStyle, perform: { _ in
            viewModel.applyStyle()
        })
    }

    private var feedsSection: some View {
        Section(header: Text("Feeds")) {
            NavigationLink(
                destination: ImportView(importViewModel: ImportViewModel(
                    viewContext: viewContext,
                    crashManager: crashManager,
                    profileManager: profileManager
                ))
            ) {
                Label("Import", systemImage: "arrow.down.doc")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("import-button")

            NavigationLink(destination: ExportView(viewModel: ExportViewModel(profileManager: profileManager))) {
                Label("Export", systemImage: "arrow.up.doc")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("export-button")

            NavigationLink(
                destination: SecurityView(viewModel: SecurityCheckViewModel(
                    viewContext: viewContext,
                    crashManager: crashManager,
                    profileManager: profileManager
                ))
            ) {
                Label("Security", systemImage: "shield.lefthalf.filled")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("security-check-button")
        }.modifier(SectionHeaderModifier())
    }

    private var historySection: some View {
        Section(header: Text("History")) {
            NavigationLink(
                destination: HistoryView(profile: profileManager.activeProfile!)
            ) {
                Label("Viewed Items", systemImage: "clock")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("view-history-button")

            #if targetEnvironment(macCatalyst)
            HStack {
                historyRetentionLabel
                Spacer()
                historyRetentionPicker
                    .frame(width: 200)
            }.modifier(FormRowModifier())
            #else
            historyRetentionPicker.modifier(FormRowModifier())
            #endif

            Button(role: .destructive) {
                showingClearHistoryAlert = true
            } label: {
                Label("Erase History", systemImage: "hourglass.bottomhalf.filled")
                    .lineLimit(1)
                    .foregroundColor(.red)
            }
            .modifier(FormRowModifier())
            .alert("Erase History?", isPresented: $showingClearHistoryAlert, actions: {
                Button("Cancel", role: .cancel) { }.accessibilityIdentifier("reset-cancel-button")
                Button("Reset", role: .destructive) {
                    viewModel.clearHistory()
                    dismiss()
                }.accessibilityIdentifier("reset-confirm-button")
            }, message: {
                Text("Memory of items viewed or marked read will be cleared.")
            })
            .accessibilityIdentifier("clear-history-button")
        }
        .modifier(SectionHeaderModifier())
        .onChange(of: historyRentionDays) { _ in
            profileManager.activeProfile?.wrappedHistoryRetention = historyRentionDays
            viewModel.saveProfile()
        }
    }

    private var dataSection: some View {
        Section(header: Text("Reset")) {
            Button(action: viewModel.clearCache) {
                Label("Clear Cache", systemImage: "bin.xmark")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("clear-cache-button")

            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Label("Reset Everything", systemImage: "clear")
                    .lineLimit(1)
                    .foregroundColor(.red)
            }
            .modifier(FormRowModifier())
            .alert("Reset Everything?", isPresented: $showingResetAlert, actions: {
                Button("Cancel", role: .cancel) { }.accessibilityIdentifier("reset-cancel-button")
                Button("Reset", role: .destructive) {
                    viewModel.resetEverything()
                    dismiss()
                }.accessibilityIdentifier("reset-confirm-button")
            }, message: {
                Text("All profiles, pages, feeds, and history will be permanently deleted.")
            })
            .accessibilityIdentifier("reset-button")
        }.modifier(SectionHeaderModifier())
    }

    private var aboutSection: some View {
        Section(header: Text("About")) {
            HStack(alignment: .bottom, spacing: 16) {
                Image(uiImage: UIImage(named: "TitleIcon") ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .cornerRadius(8)
                VStack(alignment: .leading) {
                    Text("Den").font(.system(size: 24).weight(.bold))
                    Text("v\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                Spacer()

            }.padding(.vertical, 8)

            Button(action: viewModel.openCommunity) {
                Label("Discord Community", systemImage: "person.2.wave.2")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("website-button")

            Button(action: viewModel.emailSupport) {
                Label("Email Support", systemImage: "lifepreserver")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("email-support-button")

            Button(action: viewModel.openHomepage) {
                Label("Developer Website", systemImage: "house")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("website-button")

            Button(action: viewModel.openPrivacyPolicy) {
                Label("Privacy Policy", systemImage: "hand.raised.slash")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("privacy-policy-button")
        }.modifier(SectionHeaderModifier())
    }

    private var themeSelectionLabel: some View {
        Label("Theme", systemImage: "paintbrush").lineLimit(1)
    }

    private var themeSelectionPicker: some View {
        Picker(selection: $uiStyle) {
            Text("System").tag(UIUserInterfaceStyle.unspecified)
            Text("Light").tag(UIUserInterfaceStyle.light)
            Text("Dark").tag(UIUserInterfaceStyle.dark)
        } label: {
            themeSelectionLabel
        }
    }

    private var historyRetentionLabel: some View {
        Label("Keep History", systemImage: "clock.arrow.2.circlepath").lineLimit(1)
    }

    private var historyRetentionPicker: some View {
        Picker(selection: $historyRentionDays) {
            Text("Forever").tag(0 as Int)
            Text("One Year").tag(365 as Int)
            Text("Six Months").tag(182 as Int)
            Text("Three Months").tag(90 as Int)
            Text("One Month").tag(30 as Int)
            Text("Two Weeks").tag(14 as Int)
            Text("One Week").tag(7 as Int)
        } label: {
            historyRetentionLabel
        }
    }
}
