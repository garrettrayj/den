//
//  ImportButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ImportButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var activeProfile: Profile?
    
    @State private var showingImporter: Bool = false
    
    var body: some View {
        Button {
            #if os(macOS)
            runModal()
            #endif
            
            #if os(iOS)
            showingImporter = true
            #endif
        } label: {
            Text("Import", comment: "System toolbar button label.")
        }
        #if os(iOS)
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.init(importedAs: "public.opml"), .xml],
            allowsMultipleSelection: false
        ) { result in
            guard let selectedFile: URL = try? result.get().first else { return }
            importXML(selectedFile)
        }
        #endif   
    }
    
    #if os(macOS)
    private func runModal() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.init(importedAs: "public.opml"), .xml]
        
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            self.importXML(url)
        }
    }
    #endif
    
    private func importXML(_ url: URL) {
        guard let profile = activeProfile else { return }
        
        let opmlFolders =  OPMLReader(xmlURL: url).outlineFolders
        
        opmlFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext, profile: profile)
            page.name = opmlFolder.name
            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: self.viewContext, page: page, url: opmlFeed.url)
                feed.title = opmlFeed.title
            }
        }
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            CrashUtility.handleCriticalError(error)
        }
    }
}
