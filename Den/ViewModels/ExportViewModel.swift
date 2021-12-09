//
//  ExportViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/9/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

final class ExportViewModel: ObservableObject {
    @Published var selectedPages: [Page] = []
    @Published var isFilePickerShown = false
    @Published var picker: ExportDocumentPicker?

    var allSelected: Bool {
        selectedPages.count == profileManager.activeProfile?.pagesArray.count ?? 0
    }

    var noneSelected: Bool {
        selectedPages.count == 0
    }

    private var profileManager: ProfileManager

    init(profileManager: ProfileManager) {
        self.profileManager = profileManager
    }

    func togglePage(_ page: Page) {
        if selectedPages.contains(page) {
            selectedPages.removeAll { $0 == page }
        } else {
            selectedPages.append(page)
        }
    }

    func selectAll() {
        profileManager.activeProfile?.pagesArray.forEach { page in
            if !selectedPages.contains(page) {
                selectedPages.append(page)
            }
        }
    }

    func selectNone() {
        selectedPages.removeAll()
    }

    func exportOpml() {
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
