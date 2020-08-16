//
//  FeedMessageModifier.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

struct FeedMessageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.foregroundColor(.secondary).padding().frame(maxWidth: .infinity).multilineTextAlignment(.center)
    }
}
