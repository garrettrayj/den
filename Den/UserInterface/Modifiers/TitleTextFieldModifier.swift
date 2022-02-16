//
//  TitleTextFieldModifier.swift
//  Den
//
//  Created by Garrett Johnson on 11/21/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TitleTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        Label {
            content
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
        } icon: {
            Image(systemName: "character.cursor.ibeam")
        }.modifier(FormRowModifier())
    }
}
