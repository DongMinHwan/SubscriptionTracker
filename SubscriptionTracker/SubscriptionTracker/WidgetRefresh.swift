//
//  WidgetRefresh.swift
//  SubscriptionTracker
//

import SwiftData
import WidgetKit

extension ModelContext {
    /// 위젯은 별도 프로세스라 디스크에 기록된 내용만 읽는다.
    /// 자동 저장을 기다리면 홈 화면으로 나갔을 때 아직 옛 값이 보일 수 있어,
    /// 저장을 먼저 확정한 뒤 갱신을 요청한다.
    func saveAndRefreshWidgets() {
        try? save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
