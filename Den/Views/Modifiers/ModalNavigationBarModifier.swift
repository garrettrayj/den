//
//  SimpleNavigationBarModifier.swift
//  Den
//
//  Created by Garrett Johnson on 6/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

struct ModalNavigationBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(NavigationConfigurator { nc in
                nc.navigationBar.barTintColor = .systemBackground
                nc.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
            })
    }
}

