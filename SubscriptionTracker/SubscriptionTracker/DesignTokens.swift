//
//  DesignTokens.swift
//  SubscriptionTracker
//

import SwiftUI

enum DesignTokens {
    enum Palette {
        static let background = Color(hex: 0xF2F2F7)
        static let surface = Color(hex: 0xFFFFFF)
        static let text = Color(hex: 0x1C1C1E)
        static let textSecondary = Color(hex: 0x8E8E93)
        static let accent = Color(hex: 0x1F4E79)
        static let separator = Color(hex: 0xC6C6C8)
        static let destructive = Color(hex: 0xFF3B30)
    }

    enum Typography {
        static let totalLabel = Font.system(size: 13, weight: .regular)
        static let totalValue = Font.system(size: 34, weight: .bold)
        static let rowTitle = Font.system(size: 17, weight: .regular)
        static let rowSubtitle = Font.system(size: 13, weight: .regular)
        static let rowAmount = Font.system(size: 17, weight: .regular)
        static let widgetLabel = Font.system(size: 12, weight: .regular)
        static let widgetValue = Font.system(size: 22, weight: .bold)
    }

    enum Metrics {
        static let rowHeight: CGFloat = 60
        static let screenPaddingH: CGFloat = 16
        static let totalPaddingV: CGFloat = 24
        static let cornerCard: CGFloat = 12
        static let cornerButton: CGFloat = 10
    }

    /// 런치스크린은 앱 코드가 실행되기 전에 시스템이 그리므로, 실제 값은
    /// Assets.xcassets의 LaunchBackground / LaunchLogo와 Info.plist에 들어 있다.
    /// 여기 값은 기획서 토큰과 에셋이 어긋나지 않게 두는 기준이다.
    enum Launch {
        static let background = Color(hex: 0xF2F2F7)
        static let logoSize: CGFloat = 120
    }

    /// 실제 값은 AppIcon 에셋에 구워져 있다. 위와 같은 이유로 기준만 둔다.
    enum Icon {
        static let background = Color(hex: 0x1F4E79)
        static let mark = Color(hex: 0xFFFFFF)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
