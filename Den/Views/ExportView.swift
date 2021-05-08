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
    
    @ObservedObject var mainViewModel: MainViewModel
    
    var pages: FetchedResults<Page>
    
    var body: some View {
        VStack {
            Form {
                Section(header: selectionSectionHeader) {
                    if pages.count > 0 {
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
                                    Text("\(page.subscriptions!.count) feeds").foregroundColor(.secondary)
                                }
                            }.onAppear(perform: { self.selectedPages.append(page) })
                        }
                    } else {
                        VStack(alignment: .center) {
                            Text("No pages available for export").foregroundColor(Color(UIColor.secondaryLabel))
                        }.padding().frame(maxWidth: .infinity)
                    }
                }
                
                VStack(alignment: .center) {
                    Button(action: {
                        self.export()
                        UIApplication.shared.windows[0].rootViewController!.present(self.picker!.viewController, animated: true)
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.doc")
                            Text("Save OPML File")
                        }
                    }.buttonStyle(ActionButtonStyle()).disabled(selectedPages.count == 0)
                }.frame(maxWidth: .infinity).listRowBackground(Color(UIColor.systemGroupedBackground))
            }
        }
        .navigationTitle("Export")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar() {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: backToSettings) {
                    HStack {
                        Text("Cancel")
                    }
                }
            }
        }
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
    
    private func export() {
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
    
    private func backToSettings() {
        self.mainViewModel.navSelection = "settings"
    }
}
