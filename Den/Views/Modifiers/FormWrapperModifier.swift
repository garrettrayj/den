//
//  FormSectionModifier.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FormWrapperModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(maxWidth: 980)
    }
}
