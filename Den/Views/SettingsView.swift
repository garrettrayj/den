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
    @ObservedObject var workspace: Workspace
    
    @State private var showingClearWorkspaceAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("APPEARANCE").padding(.top)) {
                    HStack {
                        Image(systemName: "circle.righthalf.fill")
                        Text("Light/Dark Mode")
                        Spacer()
                        Picker(selection: DenUserDefaults.shared.uiStyle, label: Text("Interface Style")) {
                            Text("Default").tag(UIUserInterfaceStyle.unspecified)
                            Text("Light").tag(UIUserInterfaceStyle.light)
                            Text("Dark").tag(UIUserInterfaceStyle.dark)
                        }.pickerStyle(SegmentedPickerStyle()).frame(width: 240)
                    }
                }
                
                Section(header: Text("SYNC")) {
                    HStack {
                        Toggle(isOn: .constant(true)) {
                            Image(systemName: "icloud")
                            Text("Use iCloud Sync")
                        }
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

                Section(header: Text("RESET")) {
                    Button(action: {}) {
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
                    
                    Button(action: showClearWorkspaceAlert) {
                        HStack {
                            Image(systemName: "clear")
                            Text("Reset All")
                        }.foregroundColor(Color.red)
                    }.alert(isPresented: $showingClearWorkspaceAlert) {
                        Alert(
                            title: Text("Are you sure?"),
                            message: Text("All pages and feeds will be removed. All devices will be affected if iCloud Sync is enabled."),
                            primaryButton: .destructive(Text("Reset All")) {
                                self.clearWorkspace()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
            }.modifier(FormWrapperModifier())
        }
        .navigationBarTitle("Settings")
        .navigationViewStyle(StackNavigationViewStyle())
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
    
    func showClearWorkspaceAlert() {
        self.showingClearWorkspaceAlert = true
    }
    
    func clearWorkspace() {
        do {
            let _ = Workspace.create(in: viewContext)
            viewContext.delete(workspace)
            try viewContext.save()
        } catch let error as NSError {
            print("delete fail--",error)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(workspace: Workspace())
    }
}
