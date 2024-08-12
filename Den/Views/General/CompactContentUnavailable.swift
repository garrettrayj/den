//
//  CompactContentUnavailable.swift
//  Den
//
//  Created by Garrett Johnson on 7/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CompactContentUnavailable<LabelContent: View, DescriptionContent: View, ActionsContent: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlStateActive
    #endif
    @Environment(\.isEnabled) private var isEnabled

    private var label: () -> LabelContent
    private var description: (() -> DescriptionContent)?
    private var actions: (() -> ActionsContent)?
    
    private init(
        @ViewBuilder label: @escaping () -> LabelContent,
        description: (() -> DescriptionContent)?,
        actions: (() -> ActionsContent)?
    ) {
        self.label = label
        self.description = description
        self.actions = actions
    }
    
    private var descriptionForegroundStyle: HierarchicalShapeStyle {
        #if os(macOS)
        if controlStateActive == .inactive || !isEnabled {
            return .tertiary
        } else {
            return .secondary
        }
        #else
        return .secondary
        #endif
    }

    var body: some View {
        #if os(macOS)
        if colorScheme == .dark {
            content
                .background(.fill.quinary)
                .overlay {
                    clipShape.strokeBorder(.separator).padding(.top, -1)
                }
                .clipShape(clipShape)
        } else {
            content
                .background(.background)
                .overlay {
                    clipShape.strokeBorder(.separator).padding(.top, -1)
                }
                .clipShape(clipShape)
        }
        #else
        content
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(clipShape)
        #endif
    }
    
    private var clipShape: some InsettableShape {
        UnevenRoundedRectangle(cornerRadii: .init(
            topLeading: 0,
            bottomLeading: 8,
            bottomTrailing: 8,
            topTrailing: 0
        ))
    }
    
    private var content: some View {
        VStack(spacing: 4) {
            label().labelStyle(CompactContentUnavailableLabelStyle())
            description?().font(.caption).foregroundStyle(descriptionForegroundStyle)
            actions?().font(.caption).padding(.top, 4)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding()
    }
}

extension CompactContentUnavailable {
    init(
        @ViewBuilder label: @escaping () -> LabelContent,
        @ViewBuilder description: @escaping () -> DescriptionContent,
        @ViewBuilder actions: @escaping () -> ActionsContent
    ) {
        self.label = label
        self.description = description
        self.actions = actions
    }

    init(
        @ViewBuilder label: @escaping () -> LabelContent,
        @ViewBuilder description: @escaping () -> DescriptionContent
    ) where ActionsContent == EmptyView {
        self.init(
            label: label,
            description: description,
            actions: nil
        )
    }

    init(
        @ViewBuilder label: @escaping () -> LabelContent,
        @ViewBuilder actions: @escaping () -> ActionsContent
    ) where DescriptionContent == EmptyView {
        self.init(
            label: label,
            description: nil,
            actions: actions
        )
    }
    
    init(
        @ViewBuilder label: @escaping () -> LabelContent
    ) where DescriptionContent == EmptyView, ActionsContent == EmptyView {
        self.init(
            label: label,
            description: nil,
            actions: nil
        )
    }
}
