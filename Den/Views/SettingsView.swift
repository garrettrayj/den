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
    @ObservedObject var workspace: Workspace
    @State private var showingClearWorkspaceAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("APPEARANCE")) {
                HStack {
                    Image(systemName: "circle.righthalf.fill")
                    Text("Theme")
                    Spacer()
                    Picker(selection: DenUserDefaults.shared.uiStyle, label: Text("Interface Style")) {
                        Text("Default").tag(UIUserInterfaceStyle.unspecified)
                        Text("Light").tag(UIUserInterfaceStyle.light)
                        Text("Dark").tag(UIUserInterfaceStyle.dark)
                    }.pickerStyle(SegmentedPickerStyle()).frame(width: 240)
                }
            }
            
            Section(header: Text("IMPORT AND EXPORT")) {
                NavigationLink(destination: ImportView(workspace: workspace)) {
                    Image(systemName: "arrow.down.doc")
                    Text("Import OPML")
                }
                NavigationLink(destination: ExportView(workspace: workspace)) {
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
                        Text("Reset")
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
        }
        .modifier(FormWrapperModifier())
        .navigationBarTitle("Settings")
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func clearCache() {
        cacheManager.clear(workspace: workspace)
    }
    
    func restoreDefaultSettings() {
        // Clear our UserDefaults domain
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Trigger re-render of settings controls
        self.workspace.objectWillChange.send()
        
        // Refresh UI style to apply changes to window
        DenUserDefaults.shared.applyUIStyle()
    }
    
    func showResetAlert() {
        self.showingClearWorkspaceAlert = true
    }
    
    func reset() {
        cacheManager.clear(workspace: workspace)
        
        do {
            let _ = Workspace.create(in: viewContext)
            viewContext.delete(workspace)
            try viewContext.save()
        } catch let error as NSError {
            print("Failure to clear workspace: ", error)
        }
    }
}
