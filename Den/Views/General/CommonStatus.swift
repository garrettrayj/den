//
//  CommonStatus.swift
//  Den
//
//  Created by Garrett Johnson on 10/28/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct CommonStatus: View {
    @AppStorage("Refreshed") private var refreshedTimestamp: Double?
    
    var body: some View {
        VStack {
            if let timestamp = refreshedTimestamp {
                RelativeRefreshedDate(timestamp: timestamp).font(.caption)
            }
        }
        .lineLimit(1)
    }
}
