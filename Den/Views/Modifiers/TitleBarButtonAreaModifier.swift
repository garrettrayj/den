//
//  TitleBarButtonAreaModifier.swift
//  Den
//
//  Created by Garrett Johnson on 8/2/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

struct TitleBarButtonAreaModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(.bottom, 2).frame(width: 20, height: 24, alignment: .center)
    }
}
