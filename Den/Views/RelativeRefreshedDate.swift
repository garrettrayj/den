//
//  RelativeRefreshedDate.swift
//  Den
//
//  Created by Garrett Johnson on 5/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RelativeRefreshedDate: View {
    let date: Date

    let relativeDateStyle: Date.RelativeFormatStyle = .relative(presentation: .numeric, unitsStyle: .wide)

    var body: some View {
        if -date.timeIntervalSinceNow < 60 {
            Text("Updated Just Now")
        } else {
            Text("Updated \(date.formatted(relativeDateStyle))")
        }
    }
}
