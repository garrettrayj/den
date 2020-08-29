//
//  HTMLCleaner.swift
//  Den
//
//  Created by Garrett Johnson on 6/11/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftSoup

struct HTMLCleaner {
    static let imageSourceBlacklist = ["feedburner", "npr-rss-pixel"]
    
    
    static func stripTags(_ input: String) -> String? {
        guard let doc: Document = try? SwiftSoup.parseBodyFragment(input) else { return nil } // parse html
        guard let txt = try? doc.text() else { return nil }

        return txt
    }
    
    static func extractSummaryAndImage(summaryFragment: String) -> (String?, URL?) {
        var summary: String? = nil
        var image: URL? = nil
        
        guard let doc: Document = try? SwiftSoup.parseBodyFragment(summaryFragment) else {
            return (summary, image)
        }
        
        if
            let firstImageElement = try? doc.select("img").first(where: { element in
                if
                    let src = try? element.attr("src"),
                    imageSourceBlacklist.contains(where: src.contains)
                {
                    return false
                }
                
                return true
            }),
            let imageSrc = try? firstImageElement.attr("src"),
            let imageURL = URL(string: imageSrc)
        {
            if
                let imageHeight = try? Int(firstImageElement.attr("height")),
                imageHeight < 64
            {
                // Womp womp, too short, exclude image
            } else if
                let imageWidth = try? Int(firstImageElement.attr("width")),
                imageWidth < 96
            {
                // Too skinny, exclude image
            } else if
                let mimeTypeString = try? firstImageElement.attr("type"),
                mimeTypeString != "",
                MIMETypes.ImageMIMETypes(rawValue: mimeTypeString) == nil
            {
                // Incompatible mime time, exclude image
            } else {
                image = imageURL
            }
        }
        
        if let plainSummary = try? doc.text() {
            summary = plainSummary.trimmingCharacters(in: .whitespacesAndNewlines).truncated(limit: 2000)
        }
        
        return (summary, image)
    }
}
