//
//  ContentUnavailable.swift
//  Den
//
//  Created by Garrett Johnson on 11/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ContentUnavailable<LabelContent: View, DescriptionContent: View, ActionsContent: View>: View {
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
        VStack(spacing: 16) {
            Spacer(minLength: 0)
            label().labelStyle(ContentUnavailableLabelStyle())
            description?().foregroundStyle(descriptionForegroundStyle).frame(maxWidth: 800)
            actions?().padding(.top, 4)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding()
    }
}

extension ContentUnavailable {
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
