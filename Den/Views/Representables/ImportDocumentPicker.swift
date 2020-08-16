//
//  ImportDocumentPicker.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import MobileCoreServices

/**
 Wrapper for UIDocumentPickerViewController that acts as a delegate and passes the selected file to a callback.
 Note: Using a UIReprepresentable picker (like ExportDocumentPicker) doesn't work with .import mode on Mac Catalyst.
 Adapted from https://stackoverflow.com/a/62225520/400468
 */
final class ImportDocumentPicker: NSObject {
    @ObservedObject var importViewModel: ImportView.ViewModel
    
    init(importViewModel: ImportView.ViewModel) {
        self.importViewModel = importViewModel
        super.init()
    }
    
    /// Returns the view controller that must be presented to display the picker
    lazy var viewController: UIDocumentPickerViewController = {
        let vc = UIDocumentPickerViewController(documentTypes: ["public.opml", "public.xml"], in: .import)
        vc.delegate = self
        vc.allowsMultipleSelection = false
        return vc
    }()
}

extension ImportDocumentPicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        importViewModel.pickedURL = urls.first!
        importViewModel.opmlFolders = OPMLReader(xmlURL: importViewModel.pickedURL!).outlineFolders
        importViewModel.stage = .folderSelection
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
