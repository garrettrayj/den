//
//  GroupBlockModifier.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GroupBlockModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 252, maxWidth: 424)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(8)
    }
}
