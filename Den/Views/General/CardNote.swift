//
//  CardNote.swift
//  Den
//
//  Created by Garrett Johnson on 7/22/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct CardNote<CaptionContent: View, IconContent: View>: View {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlStateActive
    #endif
    @Environment(\.isEnabled) private var isEnabled

    let title: Text
    var caption: CaptionContent?
    var icon: IconContent?

    init(
        _ title: Text,
        caption: @escaping () -> CaptionContent?,
        icon: @escaping () -> IconContent?
    ) {
        self.title = title
        self.caption = caption()
        self.icon = icon()
    }
    
    var iconForegroundStyle: HierarchicalShapeStyle {
        #if os(macOS)
        if controlStateActive == .inactive || !isEnabled {
            return .quaternary
        } else {
            return .tertiary
        }
        #else
        return .secondary
        #endif
    }
    
    var titleForegroundStyle: HierarchicalShapeStyle {
        #if os(macOS)
        if controlStateActive == .inactive || !isEnabled {
            return .tertiary
        } else {
            return .secondary
        }
        #else
        return .primary
        #endif
    }
    
    var captionForegroundStyle: HierarchicalShapeStyle {
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
        HStack {
            Spacer(minLength: 0)
            VStack(spacing: 8) {
                icon.foregroundStyle(iconForegroundStyle).font(.title2.weight(.bold))
                VStack {
                    title.fontWeight(.medium).foregroundStyle(titleForegroundStyle)
                    VStack(spacing: 8) {
                        caption.font(.caption).foregroundStyle(captionForegroundStyle)
                    }
                }
            }
            .padding()
            Spacer(minLength: 0)
        }
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

extension CardNote where CaptionContent == Never, IconContent == Never {
    init(_ title: Text) {
        self.title = title
    }
}

extension CardNote where CaptionContent == Never {
    init(_ title: Text, icon: @escaping () -> IconContent) {
        self.title = title
        self.icon = icon()
    }
}

extension CardNote where IconContent == Never {
    init(_ title: Text, caption: @escaping () -> CaptionContent) {
        self.title = title
        self.caption = caption()
    }
}
