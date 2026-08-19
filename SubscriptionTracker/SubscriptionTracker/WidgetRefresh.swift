//
//  WidgetRefresh.swift
//  SubscriptionTracker
//

import SwiftData
import WidgetKit

extension ModelContext {
    /// 저장하고, 저장된 값을 보는 쪽들을 함께 맞춘다.
    ///
    /// 위젯은 별도 프로세스라 디스크에 기록된 내용만 읽고, 알림은 미리 예약해 두는 것이라
    /// 구독이 바뀌면 다시 걸어야 한다. 자동 저장을 기다리면 둘 다 옛 값을 쓰게 되므로
    /// 저장을 먼저 확정한 뒤에 알린다.
    @MainActor
    func saveAndRefresh() {
        try? save()
        WidgetCenter.shared.reloadAllTimelines()
        PaymentNotifications.reschedule(from: self)
    }
}
