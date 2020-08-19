//
//  ContentView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var refreshManager: RefreshManager
    @FetchRequest(entity: Workspace.entity(), sortDescriptors: [])
    var workspaces: FetchedResults<Workspace>
    
    var body: some View {
        return NavigationView {
            WorkspaceView(workspace: workspaces.first!)
            WelcomeView(workspace: workspaces.first!)
        }
    }
}
