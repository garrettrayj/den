//
//  StaggeredGridStyle+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import Grid

extension StaggeredGridStyle {
    public init(availableWidth: CGFloat) {
        self.init(.vertical, tracks: calcGridTracks(availableWidth), spacing: 16)
    }
}

func calcGridTracks(_ availableWidth: CGFloat) -> Tracks {
    if availableWidth > 2000 {
        return Tracks.min(400)
    }
    
    return Tracks.min(320)
}
