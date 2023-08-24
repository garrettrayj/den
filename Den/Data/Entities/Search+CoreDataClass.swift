//
//  Search+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 8/24/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

@objc(Search)
public class Search: NSManagedObject {
    public var wrappedQuery: String {
        query ?? ""
    }
    
    static func create(
        in managedObjectContext: NSManagedObjectContext,
        profile: Profile,
        query: String
    ) -> Search {
        let search = self.init(context: managedObjectContext)
        search.id = UUID()
        search.profile = profile
        search.submitted = Date()
        search.query = query

        return search
    }
}
