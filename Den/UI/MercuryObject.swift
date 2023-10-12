//
//  MercuryObject.swift
//  Den
//
//  Created by Garrett Johnson on 10/10/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

// swiftlint:disable identifier_name
struct MercuryObject: Codable {
    var title: String?
    var content: String?
    var author: String?
    var date_published: Date?
    var lead_image_url: URL?
    var dek: String?
    var next_page_url: String?
    var url: String?
    var domain: String?
    var excerpt: String?
    var word_count: Int?
    var direction: String?
    var total_pages: Int?
    var rendered_pages: Int?
}
