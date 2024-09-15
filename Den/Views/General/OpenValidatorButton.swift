//
//  OpenValidatorButton.swift
//  Den
//
//  Created by Garrett Johnson on 1/17/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct OpenValidatorButton: View {
    var url: URL
    
    var body: some View {
        Link(destination: url) {
            Label {
                Text("Open Validator", comment: "Button label.")
            } icon: {
                Image(systemName: "stethoscope").foregroundStyle(.tint)
            }
        }
    }
}
