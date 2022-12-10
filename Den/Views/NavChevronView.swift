//
//  NavChevronView.swift
//  Den
//
//  Created by Garrett Johnson on 2/5/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NavChevronView: View {
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Image(systemName: "chevron.forward")
            .foregroundColor(
                isEnabled ? Color(UIColor.tertiaryLabel) : Color(UIColor.quaternaryLabel)
            )
            .imageScale(.small)
            .font(.body.weight(.semibold))
    }
}
