//
//  ImportDocumentPicker.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/20.
//  Copyright © 2020 Garrett Johnson
//

import MobileCoreServices
import SwiftUI

/**
 Wrapper for UIDocumentPickerViewController that acts as a delegate and passes the selected file to a callback.
 Note: Using a UIReprepresentable picker (like ExportDocumentPicker) doesn't work with .import mode on Mac Catalyst.
 Adapted from https://stackoverflow.com/a/62225520/400468
 */
final class ImportDocumentPicker: NSObject {
    var callback: ([URL]) -> Void

    init(
        callback: @escaping ([URL]) -> Void
    ) {
        self.callback = callback
        super.init()
    }

    /// Returns the view controller that must be presented to display the picker
    lazy var viewController: UIDocumentPickerViewController = {
        let viewController = UIDocumentPickerViewController(
            forOpeningContentTypes: [.init(importedAs: "public.opml"), .xml],
            asCopy: true
        )
        viewController.delegate = self
        viewController.allowsMultipleSelection = false
        return viewController
    }()
}

extension ImportDocumentPicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.callback(urls)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
