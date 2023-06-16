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

#if os(iOS)
struct ExportDocumentPicker: UIViewControllerRepresentable {
    var viewController: UIDocumentPickerViewController

    init(url: URL) {
        self.viewController = UIDocumentPickerViewController(forExporting: [url])
        self.viewController.allowsMultipleSelection = false
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

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
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            #if os(macOS)
            controller.dismiss(animated: true) {}
            #endif
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            #if os(macOS)
            controller.dismiss(animated: true) {}
            #endif
        }
    }
}
#endif
