//
//  PaymentNotifications.swift
//  SubscriptionTracker
//

import Foundation
import SwiftData
import UserNotifications

@MainActor
enum PaymentNotifications {
    /// iOS는 앱 하나가 예약해 둘 수 있는 알림을 64개로 제한하고, 넘으면 조용히 버린다.
    /// 앞으로 두 달치만 걸어 두면 월 구독은 두 번, 연 구독은 결제 두 달 전부터 잡힌다.
    /// 그 뒤의 것은 앱을 열 때 다시 계산되므로 두 달에 한 번만 열어도 끊기지 않는다.
    static let windowDays = 60

    private struct Payment {
        let name: String
        let amount: Int
    }

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }

    static func isAuthorized() async -> Bool {
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }

    /// 예약을 전부 지우고 다시 건다.
    ///
    /// 바뀐 것만 골라 고치는 편이 알뜰하지만, 이름과 금액이 알림 문구에 들어가 있어
    /// 무엇이 바뀌면 어느 알림을 고쳐야 하는지가 금세 얽힌다. 구독이 수십 개인 앱이
    /// 아니므로 통째로 다시 거는 쪽이 단순하고 어긋날 일이 없다.
    static func reschedule(from context: ModelContext, now: Date = .now, calendar: Calendar = .current) {
        let subscriptions = (try? context.fetch(FetchDescriptor<Subscription>())) ?? []
        let grouped = group(subscriptions, now: now, calendar: calendar)
        let minuteOfDay = NotificationSettings.minuteOfDay
        let isEnabled = NotificationSettings.isEnabled

        Task {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()

            guard isEnabled, await isAuthorized() else { return }

            for (due, payments) in grouped {
                guard let request = request(
                    for: payments,
                    due: due,
                    minuteOfDay: minuteOfDay,
                    now: now,
                    calendar: calendar
                ) else { continue }

                try? await center.add(request)
            }
        }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// 같은 날 결제를 한 덩어리로 묶는다. 셋이면 세 번 울리는 대신 한 번 울리고 안에 셋이 들어간다.
    private static func group(
        _ subscriptions: [Subscription],
        now: Date,
        calendar: Calendar
    ) -> [Date: [Payment]] {
        let today = calendar.startOfDay(for: now)
        guard let limit = calendar.date(byAdding: .day, value: windowDays, to: today) else { return [:] }

        var grouped: [Date: [Payment]] = [:]
        for subscription in subscriptions {
            let due = subscription.upcomingPaymentDate(now: now, calendar: calendar)
            guard due <= limit else { continue }
            grouped[due, default: []].append(
                Payment(name: subscription.name, amount: subscription.amount)
            )
        }
        return grouped
    }

    private static func request(
        for payments: [Payment],
        due: Date,
        minuteOfDay: Int,
        now: Date,
        calendar: Calendar
    ) -> UNNotificationRequest? {
        guard let fireDay = calendar.date(byAdding: .day, value: -1, to: due) else { return nil }

        var components = calendar.dateComponents([.year, .month, .day], from: fireDay)
        components.hour = minuteOfDay / 60
        components.minute = minuteOfDay % 60

        // 오늘이 결제 전날인데 알림 시각이 이미 지났으면 걸 자리가 없다.
        guard let fireDate = calendar.date(from: components), fireDate > now else { return nil }

        let sorted = payments.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        let total = sorted.reduce(0) { $0 + $1.amount }

        let content = UNMutableNotificationContent()
        if sorted.count == 1, let only = sorted.first {
            content.title = "내일 결제"
            content.body = "\(only.name) \(AmountFormat.won(only.amount))"
        } else {
            content.title = "내일 결제 \(sorted.count)건"
            content.body = "\(sorted[0].name) 외 \(sorted.count - 1)개 · \(AmountFormat.won(total))"
        }
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "payment-\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
}
