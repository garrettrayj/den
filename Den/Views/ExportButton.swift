//
//  ExportButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportButton: View {
    @Binding var activeProfile: Profile?

    @State private var showingExporter = false

    var title: String {
        "\(activeProfile?.name ?? "Untitled") \(Date().formatted(date: .abbreviated, time: .shortened))"
    }

    var body: some View {
        Button {
            #if os(macOS)
            guard let profile = activeProfile else { return }
            runModal(profile: profile, title: title)
            #endif

            #if os(iOS)
            showingExporter = true
            #endif
        } label: {
            Text("Export", comment: "Button label.")
        }
        #if os(iOS)
        .fileExporter(
            isPresented: $showingExporter,
            document: generateOPMLFileDocument(),
            contentType: UTType(importedAs: "public.opml"),
            defaultFilename: title.sanitizedForFileName()
        ) { _ in
            print("Exported")
        }
        #endif
    }

    private func generateOPMLFileDocument() -> OPMLFile? {
        let pages: [Page] = activeProfile?.pagesArray ?? []
        let generator = OPMLGenerator(title: title, pages: pages)
        return OPMLFile(initialData: generator.getData() ?? Data())
    }

    #if os(macOS)
    private func runModal(profile: Profile, title: String) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.init(importedAs: "public.opml"), .xml]
        panel.nameFieldStringValue = title.sanitizedForFileName()

        if panel.runModal() == .OK {
            guard let url = panel.url else { return }

            let opmlWriter = OPMLGenerator(title: title, pages: profile.pagesArray)
            opmlWriter.writeToFile(url: url)
        }
    }
    #endif
}
