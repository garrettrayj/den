//
//  RefreshableScrollView.swift
//  Den
//
//  Created by Garrett Johnson on 7/13/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Pull and pop refreshable scroll view.
 
 Adapted from https://swiftui-lab.com/scrollview-pull-to-refresh/
 */
struct RefreshableScrollView<Content: View>: View {
    @EnvironmentObject var refreshManager: RefreshManager

    @ObservedObject var page: Page

    @State private var previousScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var symbolRotation: Angle = .degrees(0)

    let threshold: CGFloat = 80
    let content: Content

    var body: some View {
        VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()
                    VStack { self.content }.alignmentGuide(.top, computeValue: { _ in
                        if self.refreshManager.refreshing {
                            return -self.threshold
                        } else {
                            return 0.0
                        }
                    })
                    RefreshStatusView(
                        page: page,
                        loading: $refreshManager.refreshing,
                        symbolRotation: $symbolRotation
                    )
                }
            }
            .background(FixedView())
            .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
                self.refreshLogic(values: values)
            }
        }
    }

    init(page: Page, @ViewBuilder content: () -> Content) {
        self.page = page
        self.content = content()
    }

    private func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            // Calculate scroll offset
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero

            scrollOffset  = movingBounds.minY - fixedBounds.minY

            symbolRotation = symbolRotation(scrollOffset)

            // Crossing the threshold on the way down, we start the refresh process
            if
                !refreshManager.refreshing &&
                (scrollOffset > threshold && previousScrollOffset <= threshold)
            {
                symbolRotation = .degrees(0)
                refreshManager.refresh(page: page)
            }

            // Update last scroll offset
            previousScrollOffset = scrollOffset
        }
    }

    private func symbolRotation(_ scrollOffset: CGFloat) -> Angle {
        // We will begin rotation, only after we have passed 50% of the way of reaching the threshold.
        if scrollOffset < self.threshold * 0.50 {
            return .degrees(0)
        } else {
            // Calculate rotation, based on the amount of scroll offset
            let height = Double(self.threshold)
            let distance = Double(scrollOffset)
            let vector = max(min(distance - (height * 0.6), height * 0.4), 0)
            return .degrees(180 * vector / (height * 0.4))
        }
    }

    private struct MovingView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: RefreshableKeyTypes.PrefKey.self,
                    value: [
                        RefreshableKeyTypes.PrefData(
                            vType: .movingView,
                            bounds: proxy.frame(in: .global)
                        )
                    ]
                )
            }.frame(height: 0)
        }
    }

    private struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: RefreshableKeyTypes.PrefKey.self,
                    value: [
                        RefreshableKeyTypes.PrefData(
                            vType: .fixedView,
                            bounds: proxy.frame(in: .global)
                        )
                    ]
                )
            }
        }
    }
}

struct RefreshableKeyTypes {
    enum ViewType: Int {
        case movingView
        case fixedView
    }

    struct PrefData: Equatable {
        let vType: ViewType
        let bounds: CGRect
    }

    struct PrefKey: PreferenceKey {
        static var defaultValue: [PrefData] = []

        static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
            value.append(contentsOf: nextValue())
        }

        // swiftlint:disable:next nesting
        typealias Value = [PrefData]
    }
}
