//
//  CompactContentUnavailable.swift
//  Den
//
//  Created by Garrett Johnson on 7/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct CompactContentUnavailable<LabelContent: View, DescriptionContent: View, ActionsContent: View>: View {
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
        VStack(spacing: 4) {
            label().labelStyle(CompactContentUnavailableLabelStyle())
            description?().font(.caption).foregroundStyle(descriptionForegroundStyle)
            actions?().font(.caption).padding(.top, 4)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding()
        #if os(macOS)
        .background(.background)
        #else
        .background(Color(.secondarySystemGroupedBackground))
        #endif
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: 8,
                    bottomTrailing: 8,
                    topTrailing: 0
                )
            )
        )
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
