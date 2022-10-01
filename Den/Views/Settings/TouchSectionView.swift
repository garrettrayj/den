//
//  TouchSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TouchSectionView: View {
    @Binding var hapticsEnabled: Bool

    var body: some View {
        Section(header: Text("Touch")) {
            Toggle(isOn: $hapticsEnabled) {
                Text("Enhanced Haptics")
            }
        }
    }
}
