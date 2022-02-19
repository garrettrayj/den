//
//  SidebarPageView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPageView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: SidebarPageViewModel

    var body: some View {
        Label {
            HStack {
                Text(viewModel.page.displayName)
                    #if targetEnvironment(macCatalyst)
                    .frame(height: 32)
                    .padding(.leading, 6)
                    .font(.system(size: 14))
                    #endif

                Spacer()

                Group {
                    if editMode?.wrappedValue == .inactive {
                        if viewModel.refreshing {
                            ProgressView().progressViewStyle(IconProgressStyle())
                        } else {
                            UnreadCountView(page: viewModel.page)
                        }
                    }
                }
                #if !targetEnvironment(macCatalyst)
                .padding(.trailing, 4)
                #endif

            }.lineLimit(1)
        } icon: {
            Image(systemName: viewModel.page.wrappedSymbol)
                #if targetEnvironment(macCatalyst)
                .imageScale(.large)
                #endif
        }
    }
}
