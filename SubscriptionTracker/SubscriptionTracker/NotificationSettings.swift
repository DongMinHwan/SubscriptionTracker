//
//  NotificationSettings.swift
//  SubscriptionTracker
//

import Foundation

/// 알림 설정값. 구독 데이터가 아니라서 SwiftData에 넣지 않는다.
enum NotificationSettings {
    static let isEnabledKey = "notification.isEnabled"
    static let minuteOfDayKey = "notification.minuteOfDay"

    /// 오전 9시. 출근길이나 아침에 확인하는 시간대다.
    static let defaultMinuteOfDay = 9 * 60

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: isEnabledKey)
    }

    /// 자정으로부터 몇 분 뒤에 알릴지. 시와 분을 따로 두면 둘이 어긋날 자리가 생긴다.
    static var minuteOfDay: Int {
        let stored = UserDefaults.standard.object(forKey: minuteOfDayKey) as? Int
        return stored ?? defaultMinuteOfDay
    }
}
