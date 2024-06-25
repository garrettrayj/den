//
//  OpenValidatorButton.swift
//  Den
//
//  Created by Garrett Johnson on 1/17/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OpenValidatorButton: View {
    @Environment(\.openURL) private var openURL
    
    @Bindable var feed: Feed
    
    var body: some View {
        Button {
            guard let url = feed.validatorURL else { return }
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
