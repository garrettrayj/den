//
//  BackNavigationModifier.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BackNavigationModifier: ViewModifier {
    @Environment(\.dismiss) var dismiss

    var title: String = "Back"

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Label(title, systemImage: "chevron.backward").labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .modifier(ToolbarItemOffsetModifier(alignment: .leading))
                }
            }
    }
}
