//
//  IconColorPicker.swift
//  SubscriptionTracker
//

import SwiftUI

/// 아이콘 색을 고르는 줄. 고르기 전에는 자동으로 정해진 색이 선택된 것처럼 보인다.
struct IconColorPicker: View {
    let name: String
    let automaticIndex: Int
    @Binding var colorIndex: Int

    private var selectedIndex: Int {
        colorIndex >= 0 ? colorIndex : automaticIndex
    }

    var body: some View {
        HStack(spacing: DesignTokens.Metrics.iconGap) {
            SubscriptionIcon(
                initial: Subscription.initial(for: name),
                color: DesignTokens.Palette.iconColors[selectedIndex]
            )

            Spacer(minLength: DesignTokens.Metrics.iconGap)

            HStack(spacing: 8) {
                ForEach(Array(DesignTokens.Palette.iconColors.enumerated()), id: \.offset) { index, color in
                    swatch(index: index, color: color)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("아이콘 색")
    }

    private func swatch(index: Int, color: Color) -> some View {
        let isSelected = index == selectedIndex

        return Button {
            colorIndex = index
        } label: {
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
                .overlay {
                    Circle()
                        .strokeBorder(DesignTokens.Palette.text, lineWidth: isSelected ? 2 : 0)
                        .padding(-3)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("색 \(index + 1)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
