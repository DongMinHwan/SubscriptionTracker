//
//  Subscription.swift
//  SubscriptionTracker
//

import Foundation
import SwiftData

enum BillingCycle: String, Codable, CaseIterable {
    case month
    case year

    var label: String {
        switch self {
        case .month: "매달"
        case .year: "매년"
        }
    }
}

@Model
final class Subscription {
    var name: String
    var amount: Int
    var cycle: BillingCycle
    var nextPaymentDate: Date

    init(name: String, amount: Int, cycle: BillingCycle, nextPaymentDate: Date, calendar: Calendar = .current) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.amount = amount
        self.cycle = cycle
        self.nextPaymentDate = calendar.startOfDay(for: nextPaymentDate)
    }
}

extension Subscription {
    /// 다음 결제일이 오늘보다 과거면 주기만큼 밀어 오늘 이후로 맞춘다.
    func rollForwardIfNeeded(now: Date = .now, calendar: Calendar = .current) {
        let today = calendar.startOfDay(for: now)
        guard nextPaymentDate < today else { return }

        let component: Calendar.Component = cycle == .month ? .month : .year
        var next = nextPaymentDate
        while next < today {
            guard let advanced = calendar.date(byAdding: component, value: 1, to: next) else { return }
            next = advanced
        }
        nextPaymentDate = next
    }
}

extension Array where Element == Subscription {
    /// 다음 결제일 오름차순, 같은 날이면 이름 가나다순.
    func sortedByNextPayment() -> [Subscription] {
        sorted { lhs, rhs in
            if lhs.nextPaymentDate != rhs.nextPaymentDate {
                return lhs.nextPaymentDate < rhs.nextPaymentDate
            }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }
}
