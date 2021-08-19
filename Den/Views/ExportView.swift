//
//  ExportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ExportView: View {
    @EnvironmentObject var profileManager: ProfileManager

    @State private var selectedPages: [Page] = []
    @State private var isFilePickerShown = false
    @State private var picker: ExportDocumentPicker?

    var body: some View {
        VStack {
            if profileManager.activeProfile?.pagesArray.count ?? 0 > 0 {
                Form {
                    pageList

                    VStack(alignment: .center) {
                        Button(action: exportOpml) {
                            Label("Save OPML File", systemImage: "arrow.up.doc")
                        }.buttonStyle(AccentButtonStyle()).disabled(selectedPages.count == 0)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                }
            } else {
                VStack(alignment: .center) {
                    Text("No pages available for export").foregroundColor(Color(UIColor.secondaryLabel))
                }.padding().frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Export")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pageList: some View {
        Section(header: selectionSectionHeader) {
            ForEach(profileManager.activeProfile!.pagesArray) { page in
                // .editMode doesn't work inside forms, so creating selection buttons manually
                Button { self.togglePage(page) } label: {
                    HStack {
                        if self.selectedPages.contains(page) {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "circle")
                        }
                        Text(page.wrappedName).foregroundColor(.primary).padding(.vertical, 4)
                        Spacer()
                        Text("\(page.feeds!.count) feeds").foregroundColor(.secondary)
                    }
                }.onAppear { self.selectedPages.append(page) }
            }
        }
    }

    private var allSelected: Bool {
        selectedPages.count == profileManager.activeProfile?.pagesArray.count ?? 0
    }

    private var noneSelected: Bool {
        selectedPages.count == 0
    }

    private var selectionSectionHeader: some View {
        HStack(alignment: .bottom) {
            Text("\nSELECT PAGES")
            Spacer()
            Button(action: selectAll) {
                Text("ALL")
            }.disabled(allSelected)
            Text("/")
            Button(action: selectNone) {
                Text("NONE")
            }.disabled(noneSelected)
        }.buttonStyle(ActionButtonStyle())
    }

    private func togglePage(_ page: Page) {
        if selectedPages.contains(page) {
            selectedPages.removeAll { $0 == page }
        } else {
            selectedPages.append(page)
        }
    }

    private func selectAll() {
        profileManager.activeProfile?.pagesArray.forEach { page in
            if !selectedPages.contains(page) {
                selectedPages.append(page)
            }
        }
    }

    private func selectNone() {
        selectedPages.removeAll()
    }

    private func exportOpml() {
        let exportPages: [Page] = profileManager.activeProfile!.pagesArray.compactMap { page in
            if selectedPages.contains(page) {
                return page
            }

            return nil
        }

        let opmlWriter = OPMLWriter(pages: exportPages)
        let temporaryFileURL = opmlWriter.writeToFile()
        self.picker = ExportDocumentPicker(url: temporaryFileURL, onDismiss: {})

        UIApplication.shared.windows[0].rootViewController!.present(self.picker!.viewController, animated: true)
    }
}
