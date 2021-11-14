//
//  SettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cacheManager: CacheManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var themeManager: ThemeManager

    @State var selectedTheme: UIUserInterfaceStyle = .unspecified
    @State var showingResetAlert = false
    @State var historyRentionDays: Int = 0

    var body: some View {
        Form {
            appearanceSection
            feedsSection
            historySection
            dataSection
            aboutSection
        }
        .navigationTitle("Settings")
        .onAppear(perform: loadProfile)
    }

    private var appearanceSection: some View {
        Section(header: Text("Appearance").modifier(SectionHeaderModifier())) {
            #if targetEnvironment(macCatalyst)
            HStack {
                Label("Theme", systemImage: "paintbrush")
                Spacer()
                Picker("", selection: $selectedTheme) {
                    Text("System").tag(UIUserInterfaceStyle.unspecified)
                    Text("Light").tag(UIUserInterfaceStyle.light)
                    Text("Dark").tag(UIUserInterfaceStyle.dark)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }.modifier(FormRowModifier())
            #else
            Picker(
                selection: $selectedTheme,
                label: Label("Theme", systemImage: "paintbrush"),
                content: {
                    Text("System").tag(UIUserInterfaceStyle.unspecified)
                    Text("Light").tag(UIUserInterfaceStyle.light)
                    Text("Dark").tag(UIUserInterfaceStyle.dark)
                }
            )
            #endif
        }
        .onChange(of: selectedTheme, perform: { value in
            UserDefaults.standard.setValue(value.rawValue, forKey: "UIStyle")
            themeManager.applyUIStyle()
        }).onAppear {
            selectedTheme = UIUserInterfaceStyle.init(
                rawValue: UserDefaults.standard.integer(forKey: "UIStyle")
            )!
        }
    }

    private var feedsSection: some View {
        Section(header: Text("Feeds").modifier(SectionHeaderModifier())) {
            NavigationLink(
                destination: ImportView(
                    importViewModel: ImportViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager,
                        profileManager: profileManager
                    )
                )
            ) {
                Label("Import", systemImage: "arrow.down.doc")
            }.modifier(FormRowModifier())

            NavigationLink(
                destination: ExportView(
                    viewModel: ExportViewModel(profileManager: profileManager)
                )
            ) {
                Label("Export", systemImage: "arrow.up.doc")
            }.modifier(FormRowModifier())

            NavigationLink(
                destination: SecurityCheckView(
                    viewModel: SecurityCheckViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager,
                        profileManager: profileManager
                    )
                )
            ) {
                Label("Security Check", systemImage: "checkmark.shield")
            }.modifier(FormRowModifier())
        }
    }

    private var historySection: some View {
        Section(header: Text("History").modifier(SectionHeaderModifier())) {
            #if targetEnvironment(macCatalyst)
            HStack {
                Label("Keep History", systemImage: "clock")
                Spacer()
                Picker("", selection: $historyRentionDays) {
                    Text("Forever").tag(0 as Int)
                    Text("One Year").tag(365 as Int)
                    Text("Six Months").tag(182 as Int)
                    Text("Three Months").tag(90 as Int)
                    Text("One Month").tag(30 as Int)
                    Text("Two Weeks").tag(14 as Int)
                    Text("One Week").tag(7 as Int)
                }
                .frame(maxWidth: 200)
            }.modifier(FormRowModifier())
            #else
            Picker(
                selection: $historyRentionDays,
                label: Label("Keep History", systemImage: "clock"),
                content: {
                    Text("Forever").tag(0 as Int)
                    Text("One Year").tag(365 as Int)
                    Text("Six Months").tag(182 as Int)
                    Text("Three Months").tag(90 as Int)
                    Text("One Month").tag(30 as Int)
                    Text("Two Weeks").tag(14 as Int)
                    Text("One Week").tag(7 as Int)
                }
            )
            #endif

            Button(action: clearHistory) {
                Label("Clear History", systemImage: "clear")
            }.modifier(FormRowModifier())
        }.onChange(of: historyRentionDays) { _ in
            saveProfile()
        }
    }

    private var dataSection: some View {
        Section(header: Text("Reset").modifier(SectionHeaderModifier())) {
            Button(action: clearCache) {
                Label("Empty Caches", systemImage: "bin.xmark")
            }
            .modifier(FormRowModifier())

            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Label("Reset", systemImage: "clear").symbolRenderingMode(.multicolor)
            }
            .modifier(FormRowModifier())
            .alert("Reset Everything?", isPresented: $showingResetAlert, actions: {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetEverything()
                    dismiss()
                }
            }, message: {
                Text("Settings will to defaults; Pages, feeds, and history will be deleted.")
            })
        }
    }

    private var aboutSection: some View {
        Section(header: Text("About").modifier(SectionHeaderModifier())) {
            HStack(spacing: 16) {
                Image(uiImage: UIImage(named: "TitleIcon") ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .cornerRadius(8)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Den").font(.headline)
                    Text("v\(Bundle.main.releaseVersionNumber!)")
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
            }.padding(.vertical, 8)

            Button(action: openHomepage) {
                Label("Homepage", systemImage: "house")
            }.modifier(FormRowModifier())

            Button(action: emailSupport) {
                Label("Email Support", systemImage: "lifepreserver")
            }.modifier(FormRowModifier())

            Button(action: openPrivacyPolicy) {
                Label("Privacy Policy", systemImage: "hand.raised.slash")
            }.modifier(FormRowModifier())
        }
    }

    private func loadProfile() {
        guard let profile = profileManager.activeProfile else { return }

        historyRentionDays = profile.wrappedHistoryRetention
    }

    private func saveProfile() {
        guard let profile = profileManager.activeProfile else { return }

        if historyRentionDays != profile.wrappedHistoryRetention {
            profile.wrappedHistoryRetention = historyRentionDays
        }

        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    private func clearCache() {
        cacheManager.resetFeeds()
        profileManager.activeProfile?.objectWillChange.send()
    }

    private func clearHistory() {
        profileManager.activeProfile?.historyArray.forEach { history in
            self.viewContext.delete(history)
        }

        do {
            try viewContext.save()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }

        profileManager.activeProfile?.pagesArray.forEach({ page in
            page.feedsArray.forEach { feed in
                feed.objectWillChange.send()
            }
        })
    }

    private func restoreUserDefaults() {
        // Clear our UserDefaults domain
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()

        themeManager.applyUIStyle()
    }

    private func resetEverything() {
        restoreUserDefaults()
        profileManager.resetProfiles()
    }

    private func openHomepage() {
        if let url = URL(string: "https://devsci.net") {
            UIApplication.shared.open(url)
        }
    }

    private func emailSupport() {
        // Note: "mailto:" links do not work in simulator, only on devices
        if let url = URL(string: "mailto:support@devsci.net") {
            UIApplication.shared.open(url)
        }
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: "https://devsci.net/privacy-policy.html") {
            UIApplication.shared.open(url)
        }
    }
}
