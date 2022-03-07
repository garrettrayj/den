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
        .onAppear(perform: viewModel.loadProfile)
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
                Label("Theme", systemImage: "paintbrush").lineLimit(1)
                Spacer()
                Picker("", selection: $uiStyle) {
                    Text("System").tag(UIUserInterfaceStyle.unspecified)
                    Text("Light").tag(UIUserInterfaceStyle.light)
                    Text("Dark").tag(UIUserInterfaceStyle.dark)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }.modifier(FormRowModifier())
            #else
            Picker(
                selection: $uiStyle,
                label: Label("Theme", systemImage: "paintbrush"),
                content: {
                    Text("System").tag(UIUserInterfaceStyle.unspecified)
                    Text("Light").tag(UIUserInterfaceStyle.light)
                    Text("Dark").tag(UIUserInterfaceStyle.dark)
                }
            )
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
                destination: SecurityCheckView(viewModel: SecurityCheckViewModel(
                    viewContext: viewContext,
                    crashManager: crashManager,
                    profileManager: profileManager
                ))
            ) {
                Label("Security Check", systemImage: "checkmark.shield")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("security-check-button")
        }.modifier(SectionHeaderModifier())
    }

    private var historySection: some View {
        Section(header: Text("History")) {
            Picker(selection: $viewModel.historyRentionDays) {
                Text("Forever").tag(0 as Int)
                Text("One Year").tag(365 as Int)
                Text("Six Months").tag(182 as Int)
                Text("Three Months").tag(90 as Int)
                Text("One Month").tag(30 as Int)
                Text("Two Weeks").tag(14 as Int)
                Text("One Week").tag(7 as Int)
            } label: {
                HStack {
                    Label("Keep History", systemImage: "clock").lineLimit(1)
                    Spacer()
                }
            }.modifier(FormRowModifier())

            Button(action: viewModel.clearHistory) {
                Label("Clear History", systemImage: "clear").lineLimit(1)
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("clear-history-button")
        }
        .modifier(SectionHeaderModifier())
        .onChange(of: viewModel.historyRentionDays) { _ in
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
                viewModel.showingResetAlert = true
            } label: {
                Label("Reset Everything", systemImage: "clear").symbolRenderingMode(.multicolor)
            }
            .modifier(FormRowModifier())
            .alert("Reset Everything?", isPresented: $viewModel.showingResetAlert, actions: {
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

            Button(action: viewModel.openHomepage) {
                Label("Website", systemImage: "house")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("website-button")

            Button(action: viewModel.emailSupport) {
                Label("Email Support", systemImage: "lifepreserver")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("email-support-button")

            Button(action: viewModel.openPrivacyPolicy) {
                Label("Privacy Policy", systemImage: "hand.raised.slash")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("privacy-policy-button")
        }.modifier(SectionHeaderModifier())
    }
}
