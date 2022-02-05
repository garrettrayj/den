//
//  NavChevronView.swift
//  Den
//
//  Created by Garrett Johnson on 2/5/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NavChevronView: View {
    var body: some View {
        Image(systemName: "chevron.forward")
            .foregroundColor(Color(UIColor.tertiaryLabel))
            .imageScale(.small)
            .font(.body.weight(.semibold))
    }
}
