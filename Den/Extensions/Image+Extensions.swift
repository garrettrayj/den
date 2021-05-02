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
        return self.resizable().aspectRatio(contentMode: .fit).frame(width: 16, height: 16, alignment: .center)
    }
    
    func titleBarIconView() -> some View {
        return self.imageScale(.medium)
    }
    
    func sidebarIconView() -> some View {
        return self.imageScale(.medium)
    }
}
