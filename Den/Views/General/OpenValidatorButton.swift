//
//  OpenValidatorButton.swift
//  Den
//
//  Created by Garrett Johnson on 1/17/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct OpenValidatorButton: View {
    @Environment(\.openURL) private var openURL
    
    let url: URL
    
    var body: some View {
        Button {
            openURL(url)
        } label: {
            Label {
                Text("Open Validator", comment: "Button label.")
            } icon: {
                Image(systemName: "stethoscope")
            }
        }
    }
}
