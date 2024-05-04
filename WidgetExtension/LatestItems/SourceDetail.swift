//
//  SourceDetail.swift
//  Widget Extension
//
//  Created by Garrett Johnson on 5/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import AppIntents
import CoreData
import SwiftUI

struct SourceDetail: AppEntity {
    let id: UUID
    let entityType: NSManagedObject.Type?
    let title: String
    let symbol: String?
    let favicon: Image?

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Source"
    static var defaultQuery = SourceQuery()
            
    var displayRepresentation: DisplayRepresentation {
        if let symbol = symbol {
            DisplayRepresentation(title: "\(title)", image: .init(systemName: symbol))
        } else {
            DisplayRepresentation(title: "- \(title)")
        }
    }
    
    static let allSources: [SourceDetail] = {
        var sources = [
            SourceDetail(
                id: UUID(uuidString: "866AE799-44C6-48B6-8980-3DC37B18DED7")!,
                entityType: Profile.self,
                title: "Inbox",
                symbol: "tray",
                favicon: nil
            )
        ]
        
        let context = PersistenceController.shared.container.viewContext
        let request = Page.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)]
        
        if let pages = try? context.fetch(request) {
            for page in pages {
                sources.append(SourceDetail(
                    id: page.id!,
                    entityType: Page.self,
                    title: page.wrappedName,
                    symbol: page.wrappedSymbol, 
                    favicon: nil
                ))
                
                for feed in page.feedsArray {
                    var faviconImage: Image?
                    #if os(macOS)
                    if let url = feed.feedData?.favicon,
                       let imageData = try? Data(contentsOf: url),
                       let nsImage = NSImage(data: imageData) {
                        faviconImage = Image(nsImage: nsImage)
                    }
                    #else
                    if let url = feed.feedData?.favicon,
                       let imageData = try? Data(contentsOf: url),
                       let uiImage = UIImage(data: imageData) {
                        faviconImage = Image(uiImage: uiImage)
                    }
                    #endif
                    
                    sources.append(SourceDetail(
                        id: feed.id!,
                        entityType: Feed.self,
                        title: feed.wrappedTitle, 
                        symbol: nil,
                        favicon: faviconImage
                    ))
                }
            }
        }
        
        return sources
    }()
}
