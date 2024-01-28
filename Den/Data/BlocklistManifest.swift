//
//  BlocklistSources.swift
//  Den
//
//  Created by Garrett Johnson on 1/26/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import OSLog

struct BlocklistManifest {
    struct Item: Decodable, Identifiable, Hashable {
        var id: String
        var name: String
        var description: String
        var convertedURL: URL
        var sourceURL: URL
        var supportURL: URL
        var convertedCount: Int = 0
        var errorsCount: Int = 0
    }
    
    static let url = URL(string: "https://blocklists.den.io/manifest.json")!
    
    static func fetch() async -> [Item] {
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            Logger.main.error("Unable to fetch blocklist source manifest")
            return []
        }
        
        do {
            return try JSONDecoder().decode([Item].self, from: data)
        } catch {
            Logger.main.error("Unable to decode blocklist source manifest: \(error)")
            return []
        }
    }
}
