//
//  IconProgressStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/21.
//  Copyright © 2021 Garrett Johnson
//

import SwiftUI

struct IconProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration).progressViewStyle(CircularProgressViewStyle())
    }
}
