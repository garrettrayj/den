//
//  ExportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ExportView: View {
    @EnvironmentObject private var profileManager: ProfileManager

    @State private var selectedPages: [Page] = []
    @State private var isFilePickerShown = false

    var body: some View {
        VStack {
            if profileManager.activeProfileIsEmpty {
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
            ForEach(profileManager.activeProfile!.pagesArray) { page in
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
        }.modifier(SectionHeaderModifier())
    }

    private var selectionSectionHeader: some View {
        HStack {
            Text("Select")
            Spacer()
            HStack {
                Button(action: selectAll) { Text("All") }
                    .disabled(allSelected)
                    .accessibilityIdentifier("export-select-all-button")
                Text("/").foregroundColor(.secondary)
                Button(action: selectNone) { Text("None")}
                    .disabled(noneSelected)
                    .accessibilityIdentifier("export-select-none-button")
            }
            .font(.system(size: 12))
        }
    }

    private var allSelected: Bool {
        selectedPages.count == profileManager.activeProfile?.pagesArray.count ?? 0
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
        guard let activeProfile = profileManager.activeProfile else { return }

        let exportPages: [Page] = activeProfile.pagesArray.compactMap { page in
            if selectedPages.contains(page) {
                return page
            }

            return nil
        }

        let opmlWriter = OPMLWriter(pages: exportPages)
        let temporaryFileURL = opmlWriter.writeToFile()
        let picker = ExportDocumentPicker(url: temporaryFileURL, onDismiss: {})

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
