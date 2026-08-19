//
//  Formatters.swift
//  SubscriptionTracker
//

import Foundation

enum AmountFormat {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    /// ₩17,000
    static func won(_ amount: Int) -> String {
        let number = formatter.string(from: NSNumber(value: amount)) ?? String(amount)
        return "₩\(number)"
    }
}

enum DateFormat {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter
    }()

    /// 3월 21일
    static func monthDay(_ date: Date) -> String {
        formatter.string(from: date)
    }

    /// 8월 구독 금액
    ///
    /// "이번 달"이라고만 하면 이미 나간 돈까지 세는 것처럼 읽힌다. 이 합계는 그 달 안에
    /// 결제일이 남아 있는 구독만 더하므로, 달을 못박아 오해할 자리를 줄인다.
    static func monthlyTotalLabel(_ date: Date = .now, calendar: Calendar = .current) -> String {
        "\(calendar.component(.month, from: date))월 구독 금액"
    }

    /// D-9 / D-DAY
    ///
    /// 날짜를 그대로 적으면 오늘이 며칠인지 떠올려 빼야 한다. 이 앱에서 날짜를 보는
    /// 이유는 "언제 나가는지"지 "며칠인지"가 아니라, 그 뺄셈을 앱이 대신한다.
    static func dday(_ date: Date, from now: Date = .now, calendar: Calendar = .current) -> String {
        let today = calendar.startOfDay(for: now)
        let target = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: today, to: target).day ?? 0

        // 결제일은 지나면 다음 주기로 밀리므로 음수가 나올 자리는 없다.
        // 그래도 0 이하가 오면 오늘로 본다. D-0은 읽기 어색해 D-DAY로 적는다.
        return days > 0 ? "D-\(days)" : "D-DAY"
    }
}
