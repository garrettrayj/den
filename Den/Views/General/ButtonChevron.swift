//
//  ButtonChevron.swift
//  Den
//
//  Created by Garrett Johnson on 2/5/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct ButtonChevron: View {
    var body: some View {
        Image(systemName: "chevron.forward")
            .font(.body)
            .fontWeight(.semibold)
            .imageScale(.small)
            .foregroundStyle(.fill)
    }
}
