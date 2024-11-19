//
//  PreviewHeadline.swift
//  Den
//
//  Created by Garrett Johnson on 4/30/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PreviewHeadline: View {
    let title: Text

    var body: some View {
        title.font(.headline).lineLimit(6).fixedSize(horizontal: false, vertical: true)
    }
}
