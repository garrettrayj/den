//
//  RefreshView.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//
import Foundation
import SwiftUI

struct UpdateStatusView: View {
    var page: Page
    var height: CGFloat
    var loading: Bool
    var symbolRotation: Angle

    var body: some View {
        VStack(spacing: 8) {
            if loading { // If loading, show the activity control
                Spacer()
                ActivityRep()
                Text("Updating feeds…")
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
            return Text("Never updated")
        }

        return Text("Updated \(lastRefreshed, formatter: DateFormatter.mediumShort)")
    }
}
