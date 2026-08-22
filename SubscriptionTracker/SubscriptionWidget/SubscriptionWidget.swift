//
//  SubscriptionWidget.swift
//  SubscriptionWidget
//
//  Created by 황동민 on 8/18/26.
//

import SwiftData
import SwiftUI
import WidgetKit

// 위젯 프로세스가 살아 있는 동안 하나만 만든다. ModelContainer 생성은 싸지 않다.
private let sharedContainer = SubscriptionStore.makeContainer()

struct SubscriptionEntry: TimelineEntry {
    struct NextPayment {
        let name: String
        let date: Date
        let amount: Int
    }

    let date: Date
    let monthlyTotal: Int

    /// 총액에 들어간 구독 이름들. 결제일이 빠른 순.
    /// 개수를 여기서 세야 위에 적힌 총액과 셈이 어긋나지 않는다.
    /// 다른 달에 결제되는 매년 구독은 총액에서 빠지므로 여기에도 없다.
    let monthNames: [String]

    /// 구독이 하나라도 있는지. "이번 달만 비었다"와 "아직 등록한 게 없다"는
    /// 둘 다 총액이 0원이라, 안내 문구를 고르려면 따로 알아야 한다.
    let hasSubscriptions: Bool

    /// 결제일이 빠른 순, 중간 위젯이 쓰는 세 건. 이쪽은 달을 가리지 않는다.
    let upcoming: [NextPayment]

    /// 위젯 갤러리와 프리뷰에서 보여줄 예시. 실제 데이터를 읽지 않는 자리에 쓴다.
    static let sample = SubscriptionEntry(
        date: .now,
        monthlyTotal: 257_900,
        monthNames: ["넷플릭스", "유튜브 프리미엄", "디즈니플러스", "왓챠", "밀리의 서재"],
        hasSubscriptions: true,
        upcoming: [
            NextPayment(name: "넷플릭스", date: .now, amount: 17_000),
            NextPayment(name: "유튜브 프리미엄", date: .now.addingTimeInterval(3 * 86_400), amount: 14_900),
            NextPayment(name: "밀리의 서재", date: .now.addingTimeInterval(9 * 86_400), amount: 119_000)
        ]
    )

    static let empty = SubscriptionEntry(
        date: .now,
        monthlyTotal: 0,
        monthNames: [],
        hasSubscriptions: false,
        upcoming: []
    )
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SubscriptionEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (SubscriptionEntry) -> Void) {
        completion(context.isPreview ? .sample : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SubscriptionEntry>) -> Void) {
        // 날이 바뀌면 다음 결제가 달라지고, 달이 바뀌면 총액이 달라진다.
        // 그 밖의 갱신은 앱이 저장할 때 직접 요청한다.
        let timeline = Timeline(entries: [currentEntry()], policy: .after(startOfNextDay()))
        completion(timeline)
    }

    private func currentEntry(now: Date = .now) -> SubscriptionEntry {
        let context = ModelContext(sharedContainer)
        let subscriptions = (try? context.fetch(FetchDescriptor<Subscription>())) ?? []

        // 앱을 오래 안 열면 저장된 결제일이 과거로 남아 있다. 저장은 못 하니 밀어서 계산만 한다.
        let sorted = subscriptions
            .map { (subscription: $0, date: $0.upcomingPaymentDate(now: now)) }
            .sorted { lhs, rhs in
                if lhs.date != rhs.date {
                    return lhs.date < rhs.date
                }
                return lhs.subscription.name.localizedStandardCompare(rhs.subscription.name) == .orderedAscending
            }

        return SubscriptionEntry(
            date: now,
            monthlyTotal: MonthlyTotal.amount(of: subscriptions, on: now),
            monthNames: sorted
                .filter { MonthlyTotal.includes($0.subscription, on: now) }
                .map(\.subscription.name),
            hasSubscriptions: !subscriptions.isEmpty,
            upcoming: sorted.prefix(3).map {
                SubscriptionEntry.NextPayment(
                    name: $0.subscription.name,
                    date: $0.date,
                    amount: $0.subscription.amount
                )
            }
        )
    }

    private func startOfNextDay(from now: Date = .now) -> Date {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else {
            return now.addingTimeInterval(24 * 60 * 60)
        }
        return calendar.startOfDay(for: tomorrow)
    }
}

/// 구독이 하나도 없을 때. 비워 두면 고장 난 것처럼 보이니 무엇을 하면 되는지 적는다.
private struct EmptyHint: View {
    let isStacked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if isStacked {
                Text("구독을 추가하면")
                Text("여기에 보입니다")
            } else {
                Text("구독을 추가하면 여기에 보입니다")
            }
        }
        .font(DesignTokens.Typography.widgetLabel)
        .foregroundStyle(DesignTokens.Widget.textSecondary)
    }
}

struct SubscriptionWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: SubscriptionEntry

    var body: some View {
        switch family {
        case .systemMedium:
            medium
        default:
            small
        }
    }

    /// 결제일을 함께 적으면 오늘이 결제일일 때 "곧 빠져나간다"는 뜻으로 읽힌다.
    /// 앱은 오늘 것이 이미 결제됐는지 알 수 없으므로, 작은 위젯은 금액만 말한다.
    private var small: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DateFormat.monthlyTotalLabel(entry.date))
                .font(DesignTokens.Typography.widgetLabel)
                .foregroundStyle(DesignTokens.Widget.textSecondary)

            Text(AmountFormat.won(entry.monthlyTotal))
                .font(DesignTokens.Typography.widgetValueLarge)
                .foregroundStyle(DesignTokens.Widget.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            smallCaption
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var smallCaption: some View {
        if let lead = entry.monthNames.first {
            // 한 덩어리 문장으로 두면 이름이 길 때 "유튜브 프리미엄 플…"이 되어 개수가 통째로 날아간다.
            // 이름 뒷부분보다 몇 개인지가 아까우니, 자를 쪽을 이름으로 못박는다.
            HStack(spacing: 4) {
                Text(lead)
                    .lineLimit(1)
                    .truncationMode(.tail)

                if entry.monthNames.count > 1 {
                    Text("외 \(entry.monthNames.count - 1)개")
                        .fixedSize()
                }
            }
            .font(DesignTokens.Typography.widgetLabel)
            .foregroundStyle(DesignTokens.Widget.textSecondary)
        } else if entry.hasSubscriptions {
            // 구독은 있는데 전부 다른 달에 결제되는 경우. 0원이라고만 두면 고장으로 보인다.
            Text("남은 결제 없음")
                .font(DesignTokens.Typography.widgetLabel)
                .foregroundStyle(DesignTokens.Widget.textSecondary)
        } else {
            EmptyHint(isStacked: true)
                .padding(.top, 4)
        }
    }

    /// 좌우로 나누면 목록 쪽 폭이 모자라 이름이 잘린다. 총액을 위에 한 줄로 두고
    /// 아래를 목록에 통째로 내준다.
    private var medium: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(DateFormat.monthlyTotalLabel(entry.date))
                    .font(DesignTokens.Typography.widgetLabel)
                    .foregroundStyle(DesignTokens.Widget.textSecondary)

                Text(AmountFormat.won(entry.monthlyTotal))
                    .font(DesignTokens.Typography.widgetValue)
                    .foregroundStyle(DesignTokens.Widget.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Spacer(minLength: 8)

                // 이름은 아래 목록이 이미 부르고 있으니, 여기서는 총액과 짝이 되는 개수만 둔다.
                if !entry.monthNames.isEmpty {
                    Text("구독 \(entry.monthNames.count)개")
                        .font(DesignTokens.Typography.widgetLabel)
                        .foregroundStyle(DesignTokens.Widget.textSecondary)
                        .lineLimit(1)
                }
            }

            Divider()
                .overlay(DesignTokens.Widget.separator)

            if entry.upcoming.isEmpty {
                EmptyHint(isStacked: false)
            } else {
                // 이름 길이가 제각각이라 그냥 늘어놓으면 날짜가 계단처럼 어긋난다.
                // Grid는 열 너비를 내용에 맞춰 잡아주므로 고정 폭 없이 줄이 맞는다.
                Grid(horizontalSpacing: 8, verticalSpacing: 5) {
                    ForEach(Array(entry.upcoming.enumerated()), id: \.offset) { _, payment in
                        upcomingRow(payment)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func upcomingRow(_ payment: SubscriptionEntry.NextPayment) -> some View {
        GridRow {
            Text(payment.name)
                .font(DesignTokens.Typography.widgetName)
                .foregroundStyle(DesignTokens.Widget.text)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(DateFormat.dday(payment.date))
                .font(DesignTokens.Typography.widgetLabel)
                .foregroundStyle(DesignTokens.Widget.textSecondary)
                .lineLimit(1)
                .gridColumnAlignment(.trailing)

            Text(AmountFormat.won(payment.amount))
                .font(DesignTokens.Typography.widgetName)
                .foregroundStyle(DesignTokens.Widget.text)
                .lineLimit(1)
                .gridColumnAlignment(.trailing)
        }
    }
}

struct SubscriptionWidget: Widget {
    let kind: String = "SubscriptionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SubscriptionWidgetEntryView(entry: entry)
                .containerBackground(DesignTokens.Widget.background, for: .widget)
        }
        .configurationDisplayName("구독 금액")
        .description("이번 달 안에 나갈 구독 합계와 다음 결제를 보여줍니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview("작은 것", as: .systemSmall) {
    SubscriptionWidget()
} timeline: {
    SubscriptionEntry.sample
    SubscriptionEntry.empty
}

#Preview("중간 것", as: .systemMedium) {
    SubscriptionWidget()
} timeline: {
    SubscriptionEntry.sample
    SubscriptionEntry.empty
}
