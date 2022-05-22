//
//  ThumbnailModifier.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ThumbnailModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: ImageSize.thumbnail.width, height: ImageSize.thumbnail.height)
            .background(Color(UIColor.systemFill))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
            )
            .accessibility(label: Text("Thumbnail"))
    }
}
