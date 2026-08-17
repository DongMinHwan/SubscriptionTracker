//
//  PreviewSupport.swift
//  SubscriptionTracker
//

#if DEBUG
import Foundation
import SwiftData

@MainActor
enum PreviewData {
    static func container(with subscriptions: [Subscription]) -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Subscription.self, configurations: configuration)

        for subscription in subscriptions {
            container.mainContext.insert(subscription)
        }
        return container
    }

    static func samples(calendar: Calendar = .current, now: Date = .now) -> [Subscription] {
        let today = calendar.startOfDay(for: now)

        func date(afterDays days: Int) -> Date {
            calendar.date(byAdding: .day, value: days, to: today) ?? today
        }

        return [
            Subscription(name: "넷플릭스", amount: 17000, cycle: .month, nextPaymentDate: date(afterDays: 3)),
            Subscription(name: "유튜브 프리미엄", amount: 14900, cycle: .month, nextPaymentDate: date(afterDays: 9)),
            Subscription(name: "쿠팡와우", amount: 7890, cycle: .month, nextPaymentDate: date(afterDays: 16)),
            Subscription(name: "개발자 프로그램", amount: 129000, cycle: .year, nextPaymentDate: date(afterDays: 21))
        ]
    }
}
#endif
