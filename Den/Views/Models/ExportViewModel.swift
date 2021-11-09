//
//  ExportViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/9/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

final class ExportViewModel: ObservableObject {
    @Published var selectedPages: [Page] = []
    @Published var isFilePickerShown = false
    @Published var picker: ExportDocumentPicker?

    var contentViewModel: ContentViewModel

    var allSelected: Bool {
        selectedPages.count == contentViewModel.activeProfile?.pagesArray.count ?? 0
    }

    var noneSelected: Bool {
        selectedPages.count == 0
    }

    init(contentViewModel: ContentViewModel) {
        self.contentViewModel = contentViewModel
    }

    func togglePage(_ page: Page) {
        if selectedPages.contains(page) {
            selectedPages.removeAll { $0 == page }
        } else {
            selectedPages.append(page)
        }
    }

    func selectAll() {
        contentViewModel.activeProfile?.pagesArray.forEach { page in
            if !selectedPages.contains(page) {
                selectedPages.append(page)
            }
        }
    }

    func selectNone() {
        selectedPages.removeAll()
    }

    func exportOpml() {
        guard let activeProfile = contentViewModel.activeProfile else { return }

        let exportPages: [Page] = activeProfile.pagesArray.compactMap { page in
            if selectedPages.contains(page) {
                return page
            }

            return nil
        }

        let opmlWriter = OPMLWriter(pages: exportPages)
        let temporaryFileURL = opmlWriter.writeToFile()
        self.picker = ExportDocumentPicker(url: temporaryFileURL, onDismiss: {})

        contentViewModel.hostingWindow?.rootViewController?.present(self.picker!.viewController, animated: true)
    }
}
