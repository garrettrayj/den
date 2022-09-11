//
//  PageNavView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct PageNavView: View {
    @Binding var page: Page

    var body: some View {
        NavigationLink(value: Panel.page(page)) {
            PageNavLabelView(page: page)
        }
        .accessibilityIdentifier("page-button")
    }
}
