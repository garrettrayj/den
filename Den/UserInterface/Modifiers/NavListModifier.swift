//
//  NavListModifier.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NavListModifier: ViewModifier {
    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            content.listStyle(.insetGrouped)
        } else {
            content.listStyle(.sidebar)
        }
    }
}
