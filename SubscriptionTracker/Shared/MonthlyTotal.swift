//
//  MonthlyTotal.swift
//  SubscriptionTracker
//

import Foundation

enum MonthlyTotal {
    /// 매달: 언제나 포함.
    /// 매년: 결제일의 월이 이번 달과 같을 때만 포함.
    ///
    /// 총액과 개수가 같은 기준을 쓰도록 판정만 따로 뺐다. 둘이 어긋나면
    /// 위젯에 "₩40,000 / 구독 4개"처럼 서로 안 맞는 숫자가 나란히 놓인다.
    static func includes(
        _ subscription: Subscription,
        on referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        switch subscription.cycle {
        case .month:
            return true
        case .year:
            // 앱을 오래 안 열어 결제일이 과거로 남아 있어도 같은 값이 나오도록,
            // 저장값 대신 밀어 계산한 결제일의 월을 본다.
            let upcoming = subscription.upcomingPaymentDate(now: referenceDate, calendar: calendar)
            return calendar.component(.month, from: upcoming)
                == calendar.component(.month, from: referenceDate)
        }
    }

    /// 이번 달에 실제로 빠져나갈 돈. 연 금액을 12로 나누지 않는다.
    static func amount(
        of subscriptions: [Subscription],
        on referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        subscriptions
            .filter { includes($0, on: referenceDate, calendar: calendar) }
            .reduce(0) { $0 + $1.amount }
    }
}
