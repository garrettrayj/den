//
//  Image+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 7/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

extension Image {
    func faviconView() -> some View {
        return self.resizable().scaledToFit().frame(width: 16, height: 16)
    }
    
    func titleBarIconView() -> some View {
        return self.resizable().scaledToFit().frame(width: 20, height: 20)
    }
}
