//
//  GadgetsView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetsView: View {
    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        BoardView(list: viewModel.feedViewModels, content: { feedViewModel in
            GadgetView(viewModel: feedViewModel)
        })
    }
}
