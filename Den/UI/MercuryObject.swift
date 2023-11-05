//
//  MercuryObject.swift
//  Den
//
//  Created by Garrett Johnson on 10/10/23.
//  Copyright © 2023 Garrett Johnson
//

import Foundation

// swiftlint:disable identifier_name
struct MercuryObject: Codable, Equatable {
    var title: String?
    var content: String?
    var author: String?
    var date_published: Date?
    var lead_image_url: String?
    var dek: String?
    var next_page_url: String?
    var url: String?
    var domain: String?
    var excerpt: String?
    var word_count: Int?
    var direction: String?
    var total_pages: Int?
    var rendered_pages: Int?

    static func == (lhs: MercuryObject, rhs: MercuryObject) -> Bool {
        return lhs.url == rhs.url
    }
    
    var cleanedContent: String? {
        guard let content = content else { return nil }

        return HTMLContent(source: content).sanitizedHTML()
    }
    
    var textContent: String? {
        guard let content = content else { return nil }
        
        return HTMLContent(source: content).plainText()
    }
}
