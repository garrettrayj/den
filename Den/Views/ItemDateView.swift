//
//  ItemDateView.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

import SwiftUI

struct ItemDateView: View {
    @Environment(\.isEnabled) private var isEnabled

    var date: Date
    var read: Bool

    var body: some View {
        Text("\(date, formatter: DateFormatter.mediumShort)")
            .font(.subheadline)
            .lineLimit(1)
            .foregroundColor(
                isEnabled ?
                    read ? Color(UIColor.tertiaryLabel) : .secondary
                :
                    read ? Color(UIColor.quaternaryLabel) : Color(UIColor.tertiaryLabel)
            )
    }
}
