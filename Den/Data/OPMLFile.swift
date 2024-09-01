//
//  OPMLFile.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct OPMLFile: FileDocument {
    static let readableContentTypes = [UTType(importedAs: "public.opml"), .xml]

    var data: Data = Data()

    init(initialData: Data) {
        data = initialData
    }

    init(configuration: ReadConfiguration) throws {
        if let fileData = configuration.file.regularFileContents {
            data = fileData
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
