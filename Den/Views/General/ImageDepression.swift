//
//  ImageDepression.swift
//  Den
//
//  Created by Garrett Johnson on 3/21/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ImageDepression<Content: View>: View {
    var padding: CGFloat = 8
    var cornerRadius: CGFloat = 6

    let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .padding(.vertical, padding)
            .padding(.horizontal, padding)
            .background(.fill.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
