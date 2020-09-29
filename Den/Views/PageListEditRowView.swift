//
//  PageListEditRowView.swift
//  Den
//
//  Created by Garrett Johnson on 8/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

/**
 Page list item view. Transforms name text labels into text fields when .editMode is active.
 */
struct PageListEditRowView: View {
    @ObservedObject var page: Page
    
    var body: some View {
        TextField("Name", text: $page.wrappedName)
    }
}
