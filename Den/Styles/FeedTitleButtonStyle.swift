//
//  FeedTitleButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedTitleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    var backgroundColor: Color = Color(UIColor.secondarySystemGroupedBackground)

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .foregroundColor(
                isEnabled ? .primary : .secondary
            )
            .frame(height: 32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
    }
}
