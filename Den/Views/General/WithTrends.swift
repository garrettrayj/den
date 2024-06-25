//
//  WithTrends.swift
//  Den
//
//  Created by Garrett Johnson on 1/8/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct WithTrends<Content: View>: View {
    @ViewBuilder let content: ([Trend]) -> Content

    @Query()
    private var trends: [Trend]

    var body: some View {
        content(trends)
    }

    init(
        readFilter: Bool? = nil,
        @ViewBuilder content: @escaping ([Trend]) -> Content
    ) {
        self.content = content

        var request = FetchDescriptor<Trend>(sortBy: [SortDescriptor(\Trend.title)])
        
        if readFilter != nil {
            request.predicate = #Predicate<Trend> { $0.read == readFilter! }
        }
        
        _trends = Query(request)
    }
}
