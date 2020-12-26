//
//  SettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Application settings form. Contain fields for options stored in Workspace entity (shared on all devices) and local user preferences.
 */
struct SettingsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var cacheManager: CacheManager
    @EnvironmentObject var userDefaultsManager: UserDefaultsManager
    @State private var showingClearWorkspaceAlert = false
    
    var pages: FetchedResults<Page>
    
    var body: some View {
        Form {
            Section(header: Text("APPEARANCE")) {
                HStack {
                    Image(systemName: "circle.righthalf.fill")
                    Text("Theme")
                    Spacer()
                    Picker(selection: userDefaultsManager.uiStyle, label: Text("Interface Style")) {
                        Text("Default").tag(UIUserInterfaceStyle.unspecified)
                        Text("Light").tag(UIUserInterfaceStyle.light)
                        Text("Dark").tag(UIUserInterfaceStyle.dark)
                    }.pickerStyle(SegmentedPickerStyle()).frame(width: 220)
                }
            }
            
            Section(header: Text("SUBSCRIPTIONS")) {
                NavigationLink(destination: ImportView()) {
                    Image(systemName: "arrow.down.doc")
                    Text("Import OPML")
                }
                NavigationLink(destination: ExportView(pages: pages)) {
                    Image(systemName: "arrow.up.doc")
                    Text("Export OPML")
                }
            }

            Section(header: Text("CLEAR DATA")) {
                Button(action: clearCache) {
                    HStack {
                        Image(systemName: "bin.xmark")
                        Text("Empty Cache")
                    }
                }
                
                Button(action: restoreDefaultSettings) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Restore Defaults")
                    }
                }
                
                Button(action: showResetAlert) {
                    HStack {
                        Image(systemName: "clear")
                        Text("Reset All")
                    }.foregroundColor(Color.red)
                }.alert(isPresented: $showingClearWorkspaceAlert) {
                    Alert(
                        title: Text("Are you sure you want to reset?"),
                        message: Text("All pages and feeds will be deleted. If iCloud Sync is enabled then other synced devices will also be reset."),
                        primaryButton: .destructive(Text("Reset")) {
                            self.reset()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            
            Section(header: Text("ABOUT")) {
                HStack {
                    Image("TitleIcon").resizable().scaledToFit().frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("Den").font(.headline)
                        Text("Version \(Bundle.main.releaseVersionNumber!) (\(Bundle.main.buildVersionNumber!))").font(.subheadline)
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
                        Image(systemName: "envelope")
                        Text("Email Support")
                    }
                    
                }
            }
        }
        .frame(maxWidth: 1044)
        .navigationBarTitle("Settings")
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func clearCache() {
        cacheManager.clearAll()
    }
    
    func restoreDefaultSettings() {
        // Clear our UserDefaults domain
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
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
            print("Failure to create new workspace: ", error)
        }
        
        restoreDefaultSettings()
        cacheManager.clearWebCaches()
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
}
