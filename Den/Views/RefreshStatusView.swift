//
//  UpdateStatusView.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct RefreshStatusView: View {
    @ObservedObject var page: Page

    @Binding var loading: Bool
    @Binding var symbolRotation: Angle

    let height: CGFloat = 80

    var body: some View {
        VStack(spacing: 8) {
            if loading { // If loading, show the activity control
                Spacer()
                ActivityRep()
                Text("Updating Feeds…")
            } else {
                if symbolRotation > .degrees(0) {
                    Spacer()
                    Image(systemName: "arrow.down")
                        .imageScale(.medium)
                        .fixedSize()
                        .rotationEffect(symbolRotation)

                    lastRefreshedLabel()
                }
            }
        }
        .font(.callout)
        .foregroundColor(Color.secondary)
        .fixedSize()
        .frame(height: height)
        .offset(y: -height + (loading ? height : 0.0))
    }

    private func lastRefreshedLabel() -> Text {
        guard let lastRefreshed = page.minimumRefreshedDate else {
            return Text("First Update")
        }

        return Text("Updated \(lastRefreshed, formatter: DateFormatter.mediumShort)")
    }
}
