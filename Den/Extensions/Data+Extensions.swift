//
//  Data+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/10/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

extension Data {
    var htmlAttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }

    var htmlString: String { htmlAttributedString?.string ?? "" }
}
