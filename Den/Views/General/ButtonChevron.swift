//
//  ButtonChevron.swift
//  Den
//
//  Created by Garrett Johnson on 2/5/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ButtonChevron: View {
    var body: some View {
        Image(systemName: "chevron.forward")
            .font(.body.weight(.semibold))
            .imageScale(.small)
            .foregroundStyle(.fill)
    }
}
