//
//  SubscriptionListView.swift
//  SubscriptionTracker
//

import SwiftUI
import SwiftData

struct SubscriptionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query(sort: [
        SortDescriptor(\Subscription.nextPaymentDate, order: .forward),
        SortDescriptor(\Subscription.name, order: .forward)
    ])
    private var subscriptions: [Subscription]

    @State private var isAddPresented = false

    var body: some View {
        NavigationStack {
            Group {
                if subscriptions.isEmpty {
                    emptyContent
                } else {
                    subscriptionList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DesignTokens.Palette.background)
            .navigationTitle("구독")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(DesignTokens.Palette.accent)
                    .accessibilityLabel("구독 추가")
                }
            }
            .sheet(isPresented: $isAddPresented) {
                AddSubscriptionView()
            }
        }
        .onAppear(perform: rollForwardPastPayments)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                rollForwardPastPayments()
            }
        }
    }

    private var totalSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("이번 달")
                .font(DesignTokens.Typography.totalLabel)
                .foregroundStyle(DesignTokens.Palette.textSecondary)

            Text(AmountFormat.won(MonthlyTotal.amount(of: subscriptions)))
                .font(DesignTokens.Typography.totalValue)
                .foregroundStyle(DesignTokens.Palette.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var subscriptionList: some View {
        List {
            totalSection
                .listRowInsets(EdgeInsets(
                    top: DesignTokens.Metrics.totalPaddingV,
                    leading: DesignTokens.Metrics.screenPaddingH,
                    bottom: DesignTokens.Metrics.totalPaddingV,
                    trailing: DesignTokens.Metrics.screenPaddingH
                ))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            ForEach(subscriptions) { subscription in
                NavigationLink {
                    SubscriptionDetailView(subscription: subscription)
                } label: {
                    row(for: subscription)
                }
                .listRowInsets(EdgeInsets(
                    top: 0,
                    leading: DesignTokens.Metrics.screenPaddingH,
                    bottom: 0,
                    trailing: DesignTokens.Metrics.screenPaddingH
                ))
                .listRowBackground(DesignTokens.Palette.surface)
                .listRowSeparatorTint(DesignTokens.Palette.separator)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(for subscription: Subscription) -> some View {
        HStack(spacing: DesignTokens.Metrics.screenPaddingH) {
            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(DesignTokens.Typography.rowTitle)
                    .foregroundStyle(DesignTokens.Palette.text)

                Text(DateFormat.monthDay(subscription.nextPaymentDate))
                    .font(DesignTokens.Typography.rowSubtitle)
                    .foregroundStyle(DesignTokens.Palette.textSecondary)
            }

            Spacer(minLength: 0)

            Text(AmountFormat.won(subscription.amount))
                .font(DesignTokens.Typography.rowAmount)
                .foregroundStyle(DesignTokens.Palette.text)
        }
        .frame(height: DesignTokens.Metrics.rowHeight)
    }

    private var emptyContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            totalSection
                .padding(.horizontal, DesignTokens.Metrics.screenPaddingH)
                .padding(.vertical, DesignTokens.Metrics.totalPaddingV)

            emptyState
        }
    }

    private var emptyState: some View {
        VStack(spacing: DesignTokens.Metrics.screenPaddingH) {
            Text("아직 구독이 없습니다")
                .font(DesignTokens.Typography.rowTitle)
                .foregroundStyle(DesignTokens.Palette.textSecondary)

            Button {
                isAddPresented = true
            } label: {
                Text("구독 추가")
                    .font(DesignTokens.Typography.rowTitle)
                    .foregroundStyle(DesignTokens.Palette.surface)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        DesignTokens.Palette.accent,
                        in: RoundedRectangle(cornerRadius: DesignTokens.Metrics.cornerButton)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func rollForwardPastPayments() {
        for subscription in subscriptions {
            subscription.rollForwardIfNeeded()
        }
    }
}

#if DEBUG
#Preview("빈 상태") {
    SubscriptionListView()
        .modelContainer(PreviewData.container(with: []))
        .preferredColorScheme(.light)
        .dynamicTypeSize(.large)
}

#Preview("구독 여러 개") {
    SubscriptionListView()
        .modelContainer(PreviewData.container(with: PreviewData.samples()))
        .preferredColorScheme(.light)
        .dynamicTypeSize(.large)
}
#endif
