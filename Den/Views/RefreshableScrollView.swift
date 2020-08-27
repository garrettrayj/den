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
    
    var refreshables: [Refreshable]
    var threshold: CGFloat = 80
    let content: Content

    init(refreshables: [Refreshable], @ViewBuilder content: () -> Content) {
        self.refreshables = refreshables
        self.content = content()
    }
    
    var body: some View {
        return VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()
                    VStack { self.content }.alignmentGuide(.top, computeValue: {
                        d in (self.refreshManager.isRefreshing(self.refreshables)) ? -self.threshold : 0.0
                    })
                    UpdateStatusView(refreshables: refreshables, height: self.threshold, symbolRotation: rotation)
                }
            }
            .background(FixedView())
            .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
                self.refreshLogic(values: values)
            }
        }
    }
    
    func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            // Calculate scroll offset
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
            
            self.scrollOffset  = movingBounds.minY - fixedBounds.minY
            
            self.rotation = self.symbolRotation(self.scrollOffset)
            
            // Crossing the threshold on the way down, we start the refresh process
            if !self.refreshManager.refreshing && (self.scrollOffset > self.threshold && self.previousScrollOffset <= self.threshold) {
                self.refreshManager.refresh(self.refreshables)
            }
            
            // Update last scroll offset
            self.previousScrollOffset = self.scrollOffset
        }
    }
    
    func symbolRotation(_ scrollOffset: CGFloat) -> Angle {
        // We will begin rotation, only after we have passed 60% of the way of reaching the threshold.
        if scrollOffset < self.threshold * 0.60 {
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
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .movingView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }
    
    struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))])
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

struct ActivityRep: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ActivityRep>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView()
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityRep>) {
        uiView.startAnimating()
    }
}
