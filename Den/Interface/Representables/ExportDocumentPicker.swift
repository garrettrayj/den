//
//  ExportDocumentPicker.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ExportDocumentPicker: UIViewControllerRepresentable {
    var viewController: UIDocumentPickerViewController

    init(url: URL) {
        self.viewController = UIDocumentPickerViewController(forExporting: [url])
        self.viewController.allowsMultipleSelection = false
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func updateUIViewController(
        _ uiViewController: UIDocumentPickerViewController,
        context: UIViewControllerRepresentableContext<ExportDocumentPicker>
    ) {
        //
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        viewController.delegate = context.coordinator

        return viewController
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: ExportDocumentPicker

        init(_ parent: ExportDocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            #if targetEnvironment(macCatalyst)
            controller.dismiss(animated: true) {}
            #endif
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            #if targetEnvironment(macCatalyst)
            controller.dismiss(animated: true) {}
            #endif
        }
    }
}
