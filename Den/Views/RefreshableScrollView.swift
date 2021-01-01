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
    
    @State private var previousScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var rotation: Angle = .degrees(0)
    
    var page: Page
    var threshold: CGFloat = 80
    let content: Content

    var body: some View {
        VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()
                    VStack { self.content }.alignmentGuide(.top, computeValue: { d in
                        if self.refreshManager.refreshingPages.contains(page) {
                            return -self.threshold
                        } else {
                            return 0.0
                        }
                    })
                    UpdateStatusView(
                        page: page,
                        height: threshold,
                        loading: refreshManager.refreshingPages.contains(page),
                        symbolRotation: rotation
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
    
    func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            // Calculate scroll offset
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
            
            self.scrollOffset  = movingBounds.minY - fixedBounds.minY
            
            self.rotation = self.symbolRotation(self.scrollOffset)
            
            // Crossing the threshold on the way down, we start the refresh process
            if
                !self.refreshManager.refreshingPages.contains(page) &&
                (self.scrollOffset > self.threshold && self.previousScrollOffset <= self.threshold)
            {
                self.rotation = .degrees(0)
                self.refreshManager.refresh(self.page)
            }
            
            
            // Update last scroll offset
            self.previousScrollOffset = self.scrollOffset
        }
    }
    
    func symbolRotation(_ scrollOffset: CGFloat) -> Angle {
        // We will begin rotation, only after we have passed 50% of the way of reaching the threshold.
        if scrollOffset < self.threshold * 0.50 {
            return .degrees(0)
        } else {
            // Calculate rotation, based on the amount of scroll offset
            let h = Double(self.threshold)
            let d = Double(scrollOffset)
            let v = max(min(d - (h * 0.6), h * 0.4), 0)
            return .degrees(180 * v / (h * 0.4))
        }
    }
    
    struct MovingView: View {
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
    
    struct FixedView: View {
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

        typealias Value = [PrefData]
    }
}
