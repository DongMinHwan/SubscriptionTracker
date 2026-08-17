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
}
