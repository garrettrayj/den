//
//  RefreshableScrollView.swift
//  Den
//
//  Created by Garrett Johnson on 7/13/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

// Refactored 10/13/21 with guidance from
// https://swiftuirecipes.com/blog/pull-to-refresh-with-swiftui-scrollview#drawbacks

import SwiftUI

// There are two type of positioning views - one that scrolls with the content,
// and one that stays fixed
private enum PositionType {
    case fixed, moving
}

// This struct is the currency of the Preferences, and has a type
// (fixed or moving) and the actual Y-axis value.
// It's Equatable because Swift requires it to be.
private struct Position: Equatable {
    let type: PositionType
    let yActual: CGFloat
}

// This might seem weird, but it's necessary due to the funny nature of
// how Preferences work. We can't just store the last position and merge
// it with the next one - instead we have a queue of all the latest positions.
private struct PositionPreferenceKey: PreferenceKey {
    typealias Value = [Position]

    static var defaultValue = [Position]()

    static func reduce(value: inout [Position], nextValue: () -> [Position]) {
        value.append(contentsOf: nextValue())
    }
}

private struct PositionIndicator: View {
    let type: PositionType

    var body: some View {
        GeometryReader { proxy in
            // the View itself is an invisible Shape that fills as much as possible
            Color.clear
            // Compute the top Y position and emit it to the Preferences queue
                .preference(
                    key: PositionPreferenceKey.self,
                    value: [Position(type: type, yActual: proxy.frame(in: .global).minY)]
                )
        }
    }
}

// Callback that'll trigger once refreshing is done
typealias RefreshComplete = () -> Void

// The actual refresh action that's called once refreshing starts. It has the
// RefreshComplete callback to let the refresh action let the View know
// once it's done refreshing.
typealias OnRefresh = (@escaping RefreshComplete) -> Void

// The offset threshold. 50 is a good number, but you can play
// with it to your liking.
private let THRESHOLD: CGFloat = 50

struct RefreshableScrollView<Content: View>: View {
    let onRefresh: OnRefresh // the refreshing action
    let content: Content // the ScrollView content

    @Binding var refreshing: Bool // the current state
    @State var primed: Bool = false

    // We use a custom constructor to allow for usage of a @ViewBuilder for the content
    init(
        refreshing: Binding<Bool>,
        onRefresh: @escaping OnRefresh,
        @ViewBuilder content: () -> Content
    ) {
        self.onRefresh = onRefresh
        self.content = content()

        _refreshing = refreshing
    }

    var body: some View {
        // The root view is a regular ScrollView
        ScrollView {
            // The ZStack allows us to position the PositionIndicator,
            // the content and the loading view, all on top of each other.
            ZStack(alignment: .top) {
                // The moving positioning indicator, that sits at the top
                // of the ScrollView and scrolls down with the content
                PositionIndicator(type: .moving)
                    .frame(height: 0)

                // Your ScrollView content. If we're loading, we want
                // to keep it below the loading view, hence the alignmentGuide.
                content
                    .alignmentGuide(.top, computeValue: { _ in
                        refreshing ? -THRESHOLD : 0
                    })

                // The loading view. It's offset to the top of the content unless we're loading.
                ZStack {
                    Rectangle().foregroundColor(.clear).frame(height: THRESHOLD)
                    if refreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                    }
                }.offset(y: refreshing ? 0 : -THRESHOLD)
            }
        }
        // Put a fixed PositionIndicator in the background so that we have
        // a reference point to compute the scroll offset.
        .background(PositionIndicator(type: .fixed))
        // Once the scrolling offset changes, we want to see if there should
        // be a state change.
        .onPreferenceChange(PositionPreferenceKey.self) { values in
            if !refreshing { // If we're already loading, ignore everything
                // Map the preference change action to the UI thread
                DispatchQueue.main.async {
                    // Compute the offset between the moving and fixed PositionIndicators
                    let movingY = values.first { $0.type == .moving }?.yActual ?? 0
                    let fixedY = values.first { $0.type == .fixed }?.yActual ?? 0
                    let offset = movingY - fixedY

                    // If the user pulled down below the threshold, prime the view
                    if offset > THRESHOLD && !refreshing {
                        primed = true

                        // If the view is primed and we've crossed the threshold again on the
                        // way back, trigger the refresh
                    } else if offset < THRESHOLD && primed == true {
                        primed = false
                        refreshing = true

                        onRefresh { // trigger the refreshing callback
                            // once refreshing is done, smoothly move the loading view
                            // back to the offset position
                            withAnimation {
                                self.refreshing = false
                            }
                        }
                    }
                }
            }
        }
    }
}
