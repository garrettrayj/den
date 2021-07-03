//
//  SettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import OSLog

struct SettingsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var cacheManager: CacheManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var profileManager: ProfileManager
    
    @ObservedObject var mainViewModel: MainViewModel
    
    @State private var showingClearWorkspaceAlert = false
    @State var historyRentionDays: Int = 0
    
    var body: some View {
        NavigationView {
            Form {
                appearanceSection
                opmlSection
                historySection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: loadProfile)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var appearanceSection: some View {
        Section(header: Text("\nAppearance")) {
            HStack {
                Label("Theme", systemImage: "paintpalette")
                Spacer()
                Picker(selection: themeManager.uiStyle, label: Text("Interface Style")) {
                    Text("Default").tag(UIUserInterfaceStyle.unspecified)
                    Text("Light").tag(UIUserInterfaceStyle.light)
                    Text("Dark").tag(UIUserInterfaceStyle.dark)
                }.pickerStyle(SegmentedPickerStyle()).frame(width: 220)
            }
        }
    }
    
    var opmlSection: some View {
        Section(header: Text("OPML")) {
            NavigationLink(destination: ImportView(mainViewModel: mainViewModel)) {
                Label("Import Subscriptions", systemImage: "arrow.down.doc")
            }
            
            NavigationLink(destination: ExportView(mainViewModel: mainViewModel)) {
                Label("Export Subscriptions", systemImage: "arrow.up.doc")
            }
        }
    }
    
    var historySection: some View {
        Section(header: Text("History")) {
            Picker("Keep History", selection: $historyRentionDays) {
                Text("Forever").tag(0 as Int)
                Text("One Year").tag(365 as Int)
                Text("Six Months").tag(182 as Int)
                Text("Three Months").tag(90 as Int)
                Text("One Month").tag(30 as Int)
                Text("Two Weeks").tag(14 as Int)
                Text("One Week").tag(7 as Int)
            }.onChange(of: historyRentionDays) { _ in
                saveProfile()
            }
            
            Button(action: clearHistory) {
                Label("Clear History", systemImage: "clear")
            }
            
        }
    }
    
    var dataSection: some View {
        Section(header: Text("Reset")) {
            Button(action: clearCache) {
                Label("Empty Caches", systemImage: "bin.xmark")
            }.disabled(refreshManager.refreshing)
            
            Button(action: showResetAlert) {
                Label("Reset Everything", systemImage: "clear").foregroundColor(Color(.systemRed))
            }.alert(isPresented: $showingClearWorkspaceAlert) {
                Alert(
                    title: Text("Are you sure you want to reset?"),
                    message: Text("All pages and feeds will be deleted. If iCloud Sync is enabled then other synced devices will also be reset."),
                    primaryButton: .destructive(Text("Reset")) {
                        self.reset()
                    },
                    secondaryButton: .cancel()
                )
            }.disabled(refreshManager.refreshing)
        }
    }
    
    var aboutSection: some View {
        Section(header: Text("About")) {
            HStack(spacing: 16) {
                Image("TitleIcon").resizable().scaledToFit().frame(width: 48, height: 48)
                VStack(alignment: .leading) {
                    Text("Den").font(.headline)
                    Text("Version \(Bundle.main.releaseVersionNumber!)").font(.subheadline)
                }
            }.padding(.vertical)
            
            Button(action: openHomepage) {
                Label("Homepage", systemImage: "house")
            }
            
            Button(action: emailSupport) {
                Label("Email Support", systemImage: "lifepreserver")
            }
            
            Button(action: openPrivacyPolicy) {
                Label("Privacy Policy", systemImage: "lock.shield")
            }
        }
    }
    
    func loadProfile() {
        guard let profile = mainViewModel.activeProfile else { return }
    
        historyRentionDays = profile.wrappedHistoryRetention
    }
    
    func saveProfile() {
        guard let profile = mainViewModel.activeProfile else { return }

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
    
    func clearCache() {
        cacheManager.resetFeeds()
    }
    
    private func clearHistory() {
        mainViewModel.activeProfile?.historyArray.forEach { history in
            self.viewContext.delete(history)
        }
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
        
        mainViewModel.activeProfile?.pagesArray.forEach({ page in
            page.feedsArray.forEach { feed in
                feed.objectWillChange.send()
            }
        })
    }
    
    func restoreDefaultSettings() {
        // Clear our UserDefaults domain
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        themeManager.applyUIStyle()
    }
    
    func showResetAlert() {
        self.showingClearWorkspaceAlert = true
    }
    
    func reset() {
        restoreDefaultSettings()
        profileManager.resetProfiles()
    }
    
    func openHomepage() {
        if let url = URL(string: "https://devsci.net") {
            UIApplication.shared.open(url)
        }
    }
    
    func emailSupport() {
        // Note: "mailto:" links do not work in simulator, only on devices
        if let url = URL(string: "mailto:support@devsci.net") {
            UIApplication.shared.open(url)
        }
    }
    
    func openPrivacyPolicy() {
        if let url = URL(string: "https://devsci.net/privacy-policy.html") {
            UIApplication.shared.open(url)
        }
    }
}
