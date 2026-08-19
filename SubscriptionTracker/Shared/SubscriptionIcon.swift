//
//  SubscriptionIcon.swift
//  SubscriptionTracker
//

import SwiftUI

extension Subscription {
    /// 이름의 첫 글자. 영문은 대문자로 맞춘다.
    /// 이름은 저장할 때 앞뒤 공백이 잘리므로 공백이 머리글자가 되지는 않는다.
    static func initial(for name: String) -> String {
        // 추가 화면에서 아직 이름을 치지 않았을 때가 있다. 물음표를 띄우면 잘못된 것처럼
        // 보이니, 글자 없이 색만 둔다.
        guard let first = name.first else { return "" }
        return String(first).uppercased()
    }

    /// 새 구독에 줄 색. 지금 목록에서 가장 적게 쓰인 색을 고르고, 같으면 앞 번호를 쓴다.
    ///
    /// 이름을 해시해서 고르는 방법도 있지만 여덟 칸뿐이라 둘만 있어도 같은 색이 겹친다.
    /// 색을 넣은 이유가 구분이므로, 겹치지 않는 쪽을 우선한다.
    static func suggestedColorIndex(existing: [Subscription]) -> Int {
        var used = Array(repeating: 0, count: DesignTokens.Palette.iconColors.count)
        for subscription in existing {
            used[subscription.resolvedColorIndex] += 1
        }

        var best = 0
        for index in used.indices where used[index] < used[best] {
            best = index
        }
        return best
    }

    /// 색이 정해지지 않은 구독의 색. 이름이 같으면 언제나 같은 값이 나온다.
    ///
    /// String.hashValue는 실행할 때마다 결과가 달라지도록 만들어져 있어, 그것으로 색을
    /// 정하면 앱을 껐다 켤 때마다 목록의 색이 뒤바뀐다. 그래서 직접 더한다.
    static func autoColorIndex(for name: String) -> Int {
        var hash: UInt = 5381
        for scalar in name.unicodeScalars {
            hash = hash &* 33 &+ UInt(scalar.value)
        }
        return Int(hash % UInt(DesignTokens.Palette.iconColors.count))
    }

    var initial: String {
        Self.initial(for: name)
    }

    var resolvedColorIndex: Int {
        let count = DesignTokens.Palette.iconColors.count
        guard colorIndex >= 0 else { return Self.autoColorIndex(for: name) }
        return colorIndex % count
    }

    var iconColor: Color {
        DesignTokens.Palette.iconColors[resolvedColorIndex]
    }
}

struct SubscriptionIcon: View {
    let initial: String
    let color: Color

    init(initial: String, color: Color) {
        self.initial = initial
        self.color = color
    }

    init(subscription: Subscription) {
        self.init(initial: subscription.initial, color: subscription.iconColor)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: DesignTokens.Metrics.iconCorner, style: .continuous)
            .fill(color)
            .frame(
                width: DesignTokens.Metrics.iconSize,
                height: DesignTokens.Metrics.iconSize
            )
            .overlay {
                Text(initial)
                    .font(DesignTokens.Typography.iconInitial)
                    .foregroundStyle(DesignTokens.Palette.surface)
            }
            // 머리글자는 이름을 줄인 것뿐이라, 읽어 주면 "넷, 넷플릭스"가 되어 방해가 된다.
            .accessibilityHidden(true)
    }
}
