//
//  ExportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import AEXML

struct ExportView: View {
    @State private var selectedPages: [Page] = []
    @State private var isFilePickerShown = false
    @State private var picker: ExportDocumentPicker?
    
    @FetchRequest(entity: Page.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)])
    var pages: FetchedResults<Page>
    
    var body: some View {
        VStack {
            Form {
                Section(header: selectionSectionHeader) {
                    List(pages) { page in
                        // .editMode doesn't work inside forms, so creating selection buttons manually
                        Button(action: { self.togglePage(page) }) {
                            HStack {
                                if self.selectedPages.contains(page) {
                                    Image(systemName: "checkmark.circle.fill")
                                } else {
                                    Image(systemName: "circle")
                                }
                                
                                Text(page.wrappedName).foregroundColor(.primary)
                                Spacer()
                                Text("\(page.feeds!.count) feeds").foregroundColor(.secondary)
                            }
                        }.onAppear(perform: { self.selectedPages.append(page) })
                    }
                }
                Section() {
                    Button(action: {
                        self.export()
                        UIApplication.shared.windows[0].rootViewController!.present(self.picker!.viewController, animated: true)
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.on.square")
                            Text("Save OPML File")
                        }
                    }
                }
            }.frame(maxWidth: 980)
        }
        .navigationBarTitle("Export", displayMode: .inline)
    }
    
    private var allSelected: Bool {
        selectedPages.count == pages.count
    }
    
    private var noneSelected: Bool {
        selectedPages.count == 0
    }
    
    private var selectionSectionHeader: some View {
        HStack {
            Text("SELECT PAGES")
            Spacer()
            Button(action: selectAll) {
                Text("ALL")
            }.disabled(allSelected)
            Text("/")
            Button(action: selectNone) {
                Text("NONE")
            }.disabled(noneSelected)
        }
    }
    
    private func togglePage(_ page: Page) {
        if selectedPages.contains(page) {
            selectedPages.removeAll { $0 == page }
        } else {
            selectedPages.append(page)
        }
    }
    
    private func selectAll() {
        pages.forEach { page in
            if !selectedPages.contains(page) {
                selectedPages.append(page)
            }
        }
    }
    
    private func selectNone() {
        selectedPages.removeAll()
    }
    
    func export() {
        let exportPages: [Page] = pages.compactMap { page in
            if selectedPages.contains(page) {
                return page
            }
            
            return nil
        }
        
        let opmlWriter = OPMLWriter(pages: exportPages)
        let temporaryFileURL = opmlWriter.writeToFile()
        self.picker = ExportDocumentPicker(url: temporaryFileURL, onDismiss: {})
    }
}
