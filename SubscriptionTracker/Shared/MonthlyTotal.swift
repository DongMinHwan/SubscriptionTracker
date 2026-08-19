//
//  MonthlyTotal.swift
//  SubscriptionTracker
//

import Foundation

enum MonthlyTotal {
    /// 다음 결제일이 이번 달 안에 있으면 포함한다. 주기는 보지 않는다.
    ///
    /// 연도까지 함께 본다. 월만 비교하면 내년 8월에 나갈 연 구독이 올해 8월 총액에
    /// 섞여 들어간다. 목록에는 D-364로 보이는 항목이 "이번 달"에 더해져 있는 셈이라
    /// 숫자와 화면이 어긋난다.
    ///
    /// 총액과 개수가 같은 기준을 쓰도록 판정만 따로 뺐다. 둘이 어긋나면
    /// 위젯에 "₩40,000 / 구독 4개"처럼 서로 안 맞는 숫자가 나란히 놓인다.
    static func includes(
        _ subscription: Subscription,
        on referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        // 앱을 오래 안 열어 결제일이 과거로 남아 있어도 같은 값이 나오도록,
        // 저장값 대신 밀어 계산한 결제일을 본다.
        let upcoming = subscription.upcomingPaymentDate(now: referenceDate, calendar: calendar)
        return calendar.isDate(upcoming, equalTo: referenceDate, toGranularity: .month)
    }

    /// 이번 달 안에 결제일이 남아 있는 구독의 합. 연 금액을 12로 나누지 않는다.
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
