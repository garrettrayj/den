//
//  ShowcaseItemView.swift
//  Den
//
//  Created by Garrett Johnson on 5/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseItemView: View {
    @ObservedObject var item: Item

    var body: some View {
        ItemPreviewView(item: item)
            .modifier(GroupBlockModifier())
            .transition(.move(edge: .top))
    }
}
