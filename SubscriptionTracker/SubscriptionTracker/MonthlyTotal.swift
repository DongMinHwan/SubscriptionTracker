//
//  MonthlyTotal.swift
//  SubscriptionTracker
//

import Foundation

enum MonthlyTotal {
    /// 매달: 금액 전부 합산.
    /// 매년: 다음 결제일의 월이 이번 달과 같으면 금액 포함, 아니면 제외. 연 금액을 12로 나누지 않는다.
    static func amount(
        of subscriptions: [Subscription],
        on referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let currentMonth = calendar.component(.month, from: referenceDate)

        return subscriptions.reduce(into: 0) { total, subscription in
            switch subscription.cycle {
            case .month:
                total += subscription.amount
            case .year:
                let paymentMonth = calendar.component(.month, from: subscription.nextPaymentDate)
                if paymentMonth == currentMonth {
                    total += subscription.amount
                }
            }
        }
    }
}
