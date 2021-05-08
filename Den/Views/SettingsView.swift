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
    
    @ObservedObject var mainViewModel: MainViewModel
    
    @State private var showingClearWorkspaceAlert = false
    
    var pages: FetchedResults<Page>
    
    var body: some View {
        Form {
            appearanceSection
            opmlSection
            dataSection
            aboutSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var appearanceSection: some View {
        Section(header: Text("Appearance")) {
            HStack {
                Image(systemName: "circle.righthalf.fill")
                Text("Theme").lineLimit(1)
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
            Button(action: { mainViewModel.navSelection = "import" }) {
                HStack {
                    Image(systemName: "arrow.down.doc")
                    Text("Import Subscriptions")
                }
            }
            
            Button(action: { mainViewModel.navSelection = "export" }) {
                HStack {
                    Image(systemName: "arrow.up.doc")
                    Text("Export Subscriptions")
                }
            }
        }
    }
    
    var dataSection: some View {
        Section(header: Text("Data")) {
            Button(action: clearCache) {
                HStack {
                    Image(systemName: "bin.xmark")
                    Text("Empty Caches")
                }
            }.disabled(refreshManager.refreshing)
            
            Button(action: restoreDefaultSettings) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Restore Default Preferences")
                }
            }
            
            Button(action: showResetAlert) {
                HStack {
                    Image(systemName: "clear")
                    Text("Reset All")
                }.foregroundColor(refreshManager.refreshing ? Color(.secondaryLabel) : Color(.systemRed))
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
            HStack {
                Image("TitleIcon").resizable().scaledToFit().frame(width: 48, height: 48)
                VStack(alignment: .leading) {
                    Text("Den").font(.headline)
                    Text("Version \(Bundle.main.releaseVersionNumber!)").font(.subheadline)
                }
            }.padding(.vertical)
            
            Button(action: openHomepage) {
                HStack {
                    Image(systemName: "house")
                    Text("Homepage")
                }
                
            }
            
            Button(action: emailSupport) {
                HStack {
                    Image(systemName: "lifepreserver")
                    Text("Email Support")
                }
                
            }
            
            Button(action: openPrivacyPolicy) {
                HStack {
                    Image(systemName: "lock.shield")
                    Text("Privacy Policy")
                }
                
            }
        }
    }
    
    func clearCache() {
        cacheManager.resetFeeds()
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
        pages.forEach { page in
            self.viewContext.delete(page)
        }
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
        
        restoreDefaultSettings()
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
