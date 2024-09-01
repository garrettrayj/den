//
//  DeleteLabel.swift
//  Den
//
//  Created by Garrett Johnson on 1/11/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct DeleteLabel: View {
    var symbol = "trash"
    
    var body: some View {
        Label {
            Text("Delete", comment: "Button label.")
        } icon: {
            Image(systemName: symbol)
        }
        .symbolRenderingMode(.multicolor)
    }
}
