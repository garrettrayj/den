//
//  WithTrends.swift
//  Den
//
//  Created by Garrett Johnson on 1/8/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
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

        let request = Trend.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Trend.title, ascending: true)]
        
        if readFilter != nil {
            request.predicate = NSPredicate(format: "read = %@", NSNumber(value: readFilter!))
        }
        
        _trends = FetchRequest(fetchRequest: request)
    }
}
