//
//  WithTrends.swift
//  Den
//
//  Created by Garrett Johnson on 1/8/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct WithTrends<Content: View>: View {
    @ViewBuilder let content: (FetchedResults<Trend>) -> Content

    @FetchRequest(sortDescriptors: [])
    private var trends: FetchedResults<Trend>

    var body: some View {
        content(trends)
    }

    init(
        readFilter: Bool? = nil,
        @ViewBuilder content: @escaping (FetchedResults<Trend>) -> Content
    ) {
        self.content = content

        var predicates: [NSPredicate] = []
        
        if readFilter != nil {
            predicates.append(NSPredicate(format: "read = %@", NSNumber(value: readFilter!)))
        }
        
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        
        let request: NSFetchRequest<Trend> = Trend.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Trend.title, ascending: true)]
        request.predicate = compoundPredicate
        
        _trends = FetchRequest(fetchRequest: request)
    }
}
