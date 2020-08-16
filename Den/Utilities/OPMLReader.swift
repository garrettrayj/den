//
//  OPMLReader.swift
//  Den
//
//  Created by Garrett Johnson on 6/13/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import AEXML

struct OPMLFolder: Hashable {
    var name: String
    var feeds: [OPMLFeed] = []
}

struct OPMLFeed: Hashable {
    var title: String
    var url: URL
}

class OPMLReader {
    var xmlURL: URL
    var data: Data?
    var outlineFolders: [OPMLFolder] = []
    
    init(xmlURL: URL) {
        self.xmlURL = xmlURL
        self.data = try? Data(contentsOf: xmlURL)
        
        // Populate outline with XML data
        guard let data = data else { return }
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            parseDocument(xmlDoc: xmlDoc)
        }
        catch {
            print("\(error)")
        }
    }
    
    func parseDocument(xmlDoc: AEXMLDocument) {
        let folders = xmlDoc.root["body"].allDescendants { element in
            element.attributes["title"] != nil && element.attributes["xmlUrl"] == nil
        }
        
        folders.forEach { folderElement in
            var opmlFolder = OPMLFolder(name: folderElement.attributes["title"] ?? "Uncategorized")
            let feeds = folderElement.allDescendants { element in
                element.attributes["xmlUrl"] != nil
            }
            
            feeds.forEach({ feedElement in
                guard
                    let title = feedElement.attributes["title"],
                    let xmlURLString = feedElement.attributes["xmlUrl"],
                    let xmlURL = URL(string: xmlURLString)
                else {
                    return
                }
                
                let feed = OPMLFeed(title: title, url: xmlURL)
                opmlFolder.feeds.append(feed)
            })
            
            outlineFolders.append(opmlFolder)
        }
    }
}
