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
    @EnvironmentObject var cacheManager: CacheManager

    @ObservedObject var viewModel: SettingsViewModel

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
                Label("Theme", systemImage: "paintbrush").padding(.vertical, 4)
                Spacer()
                Picker("", selection: $viewModel.selectedTheme) {
                    Text("System").tag(UIUserInterfaceStyle.unspecified)
                    Text("Light").tag(UIUserInterfaceStyle.light)
                    Text("Dark").tag(UIUserInterfaceStyle.dark)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            #else
            Picker(
                selection: $viewModel.selectedTheme,
                label: Label("Theme", systemImage: "paintbrush"),
                content: {
                    Text("System").tag(UIUserInterfaceStyle.unspecified)
                    Text("Light").tag(UIUserInterfaceStyle.light)
                    Text("Dark").tag(UIUserInterfaceStyle.dark)
                }
            )
            #endif
        }
        .onChange(of: viewModel.selectedTheme, perform: { value in
            UserDefaults.standard.setValue(value.rawValue, forKey: "UIStyle")
            viewModel.contentViewModel.applyUIStyle()
        }).onAppear {
            viewModel.selectedTheme = UIUserInterfaceStyle.init(
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
                        contentViewModel: viewModel.contentViewModel
                    )
                )
            ) {
                Label("Import", systemImage: "arrow.down.doc").padding(.vertical, 4)
            }

            NavigationLink(
                destination: ExportView(
                    viewModel: ExportViewModel(
                        contentViewModel: viewModel.contentViewModel
                    )
                )
            ) {
                Label("Export", systemImage: "arrow.up.doc").padding(.vertical, 4)
            }

            NavigationLink(
                destination: SecurityCheckView(
                    viewModel: SecurityCheckViewModel(
                        viewContext: viewContext,
                        contentViewModel: viewModel.contentViewModel
                    )
                )
            ) {
                Label("Security Check", systemImage: "checkmark.shield").padding(.vertical, 4)
            }
        }
    }

    private var historySection: some View {
        Section(header: Text("History").modifier(SectionHeaderModifier())) {
            #if targetEnvironment(macCatalyst)
            HStack {
                Label("Keep History", systemImage: "clock").padding(.vertical, 4)
                Spacer()
                Picker("", selection: $viewModel.historyRentionDays) {
                    Text("Forever").tag(0 as Int)
                    Text("One Year").tag(365 as Int)
                    Text("Six Months").tag(182 as Int)
                    Text("Three Months").tag(90 as Int)
                    Text("One Month").tag(30 as Int)
                    Text("Two Weeks").tag(14 as Int)
                    Text("One Week").tag(7 as Int)
                }
                .frame(maxWidth: 200)
            }
            #else
            Picker(
                selection: $viewModel.historyRentionDays,
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
                Label("Clear History", systemImage: "clear").padding(.vertical, 4)
            }
        }.onChange(of: viewModel.historyRentionDays) { _ in
            saveProfile()
        }
    }

    private var dataSection: some View {
        Section(header: Text("Reset").modifier(SectionHeaderModifier())) {
            Button(action: clearCache) {
                Label("Empty Caches", systemImage: "bin.xmark").padding(.vertical, 4)
            }

            Button(action: showResetAlert) {
                Label("Reset Everything", systemImage: "clear")
                    .foregroundColor(.red)
                    .padding(.vertical, 4)
            }.alert(isPresented: $viewModel.showingClearWorkspaceAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("All pages and feeds will be permanently removed."),
                    primaryButton: .destructive(Text("Reset")) {
                        self.resetEverything()
                    },
                    secondaryButton: .cancel()
                )
            }
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
                Label("Homepage", systemImage: "house").padding(.vertical, 4)
            }

            Button(action: emailSupport) {
                Label("Email Support", systemImage: "lifepreserver").padding(.vertical, 4)
            }

            Button(action: openPrivacyPolicy) {
                Label("Privacy Policy", systemImage: "hand.raised.slash").padding(.vertical, 4)
            }
        }
    }

    private func loadProfile() {
        guard let profile = viewModel.contentViewModel.activeProfile else { return }

        viewModel.historyRentionDays = profile.wrappedHistoryRetention
    }

    private func saveProfile() {
        guard let profile = viewModel.contentViewModel.activeProfile else { return }

        if viewModel.historyRentionDays != profile.wrappedHistoryRetention {
            profile.wrappedHistoryRetention = viewModel.historyRentionDays
        }

        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                viewModel.contentViewModel.handleCriticalError(error)
            }
        }
    }

    private func clearCache() {
        cacheManager.resetFeeds()
    }

    private func clearHistory() {
        viewModel.contentViewModel.activeProfile?.historyArray.forEach { history in
            self.viewContext.delete(history)
        }

        do {
            try viewContext.save()
        } catch let error as NSError {
            viewModel.contentViewModel.handleCriticalError(error)
        }

        viewModel.contentViewModel.activeProfile?.pagesArray.forEach({ page in
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

        viewModel.contentViewModel.applyUIStyle()
    }

    private func showResetAlert() {
        viewModel.showingClearWorkspaceAlert = true
    }

    private func resetEverything() {
        restoreUserDefaults()
        viewModel.contentViewModel.resetProfiles()
        viewModel.contentViewModel.pageViewModels = []
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
