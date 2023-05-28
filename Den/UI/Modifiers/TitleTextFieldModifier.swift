//
//  TitleTextFieldModifier.swift
//  Den
//
//  Created by Garrett Johnson on 11/21/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TitleTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        Label {
            content
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        } icon: {
            Image(systemName: "character.cursor.ibeam")
        }
    }
}
