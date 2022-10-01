//
//  ExportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ExportView: View {
    let profile: Profile

    @State private var selectedPages: [Page] = []
    @State private var isFilePickerShown = false

    var body: some View {
        VStack {
            if profile.feedsArray.isEmpty {
                StatusBoxView(message: Text("Profile Empty"), symbol: "folder.badge.questionmark")
            } else {
                Form {
                    pageListSection

                    Section {
                        Button {
                            exportOpml()
                        } label: {
                            Label("Save OPML File", systemImage: "arrow.up.doc")
                        }
                        .modifier(ProminentButtonModifier())
                        .disabled(selectedPages.isEmpty)
                        .accessibilityIdentifier("export-opml-button")
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Export")
    }

    private var pageListSection: some View {
        Section(header: selectionSectionHeader) {
            ForEach(profile.pagesArray) { page in
                // .editMode doesn't work inside forms, so creating selection buttons manually
                Button { self.togglePage(page) } label: {
                    Label {
                        HStack {
                            Text(page.wrappedName).foregroundColor(.primary)
                            Spacer()
                            Text("\(page.feeds?.count ?? 0) feeds")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    } icon: {
                        if self.selectedPages.contains(page) {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "circle")
                        }
                    }.lineLimit(1)
                }
                .modifier(FormRowModifier())
                .onAppear { self.selectedPages.append(page) }
                .accessibilityIdentifier("export-toggle-page-button")
            }
        }
    }

    private var selectionSectionHeader: some View {
        PageSelectionView(
            allSelected: allSelected,
            noneSelected: noneSelected,
            selectAll: selectAll,
            selectNone: selectNone
        )
    }

    private var allSelected: Bool {
        selectedPages.count == profile.pagesArray.count
    }

    private var noneSelected: Bool {
        selectedPages.count == 0
    }

    private func togglePage(_ page: Page) {
        if selectedPages.contains(page) {
            selectedPages.removeAll { $0 == page }
        } else {
            selectedPages.append(page)
        }
    }

    private func selectAll() {
        profile.pagesArray.forEach { page in
            if !selectedPages.contains(page) {
                selectedPages.append(page)
            }
        }
    }

    private func selectNone() {
        selectedPages.removeAll()
    }

    private func exportOpml() {
        let exportPages: [Page] = profile.pagesArray.compactMap { page in
            if selectedPages.contains(page) {
                return page
            }

            return nil
        }

        let opmlWriter = OPMLWriter(pages: exportPages)
        let temporaryFileURL = opmlWriter.writeToFile()
        let picker = ExportDocumentPicker(url: temporaryFileURL)

        let scenes = UIApplication.shared.connectedScenes
        if
            let windowScene = scenes.first as? UIWindowScene,
            let window = windowScene.windows.first,
            let rootViewController = window.rootViewController
        {
            rootViewController.present(picker.viewController, animated: true)
        }
    }
}
