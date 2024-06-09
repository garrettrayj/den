//
//  Blocklist.swift
//  Den
//
//  Created by Garrett Johnson on 6/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//
//

import Foundation
import SwiftData
import SwiftUI

@Model 
class Blocklist {
    var id: UUID?
    var name: String?
    var url: URL?
    
    init(
        id: UUID? = nil,
        name: String? = nil,
        url: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.url = url
    }
    
    var nameText: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Default content filter name.")
        }

        return Text(wrappedName)
    }

    var wrappedName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    var urlString: String {
        get { url?.absoluteString ?? "" }
        set { url = URL(string: newValue) }
    }

    var blocklistStatus: BlocklistStatus? {
        var fetchDescriptor = FetchDescriptor<BlocklistStatus>()
        fetchDescriptor.predicate = #Predicate<BlocklistStatus> { $0.blocklistId == id }
        
        return try? modelContext?.fetch(fetchDescriptor).first
    }

    static func create(in modelContext: ModelContext) -> Blocklist {
        let blocklist = Blocklist()
        blocklist.id = UUID()

        modelContext.insert(blocklist)
        
        return blocklist
    }
}
