//
//  SubscriptionDetailView.swift
//  SubscriptionTracker
//

import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let subscription: Subscription

    @State private var name: String
    @State private var amountText: String
    @State private var cycle: BillingCycle
    @State private var nextPaymentDate: Date
    @State private var isDeleteAlertPresented = false

    init(subscription: Subscription) {
        self.subscription = subscription
        _name = State(initialValue: subscription.name)
        _amountText = State(initialValue: String(subscription.amount))
        _cycle = State(initialValue: subscription.cycle)
        _nextPaymentDate = State(initialValue: subscription.nextPaymentDate)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var amount: Int {
        Int(amountText) ?? 0
    }

    private var isValid: Bool {
        !trimmedName.isEmpty && amount >= 1
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("이름")
                        .font(DesignTokens.Typography.rowTitle)
                        .foregroundStyle(DesignTokens.Palette.text)

                    Spacer(minLength: DesignTokens.Metrics.screenPaddingH)

                    TextField("넷플릭스", text: $name)
                        .font(DesignTokens.Typography.rowTitle)
                        .foregroundStyle(DesignTokens.Palette.text)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("금액")
                        .font(DesignTokens.Typography.rowTitle)
                        .foregroundStyle(DesignTokens.Palette.text)

                    Spacer(minLength: DesignTokens.Metrics.screenPaddingH)

                    TextField("0", text: $amountText)
                        .font(DesignTokens.Typography.rowTitle)
                        .foregroundStyle(DesignTokens.Palette.text)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: amountText) { _, newValue in
                            let digits = newValue.filter(\.isNumber)
                            if digits != newValue {
                                amountText = digits
                            }
                        }

                    Text("원")
                        .font(DesignTokens.Typography.rowTitle)
                        .foregroundStyle(DesignTokens.Palette.textSecondary)
                }

                HStack {
                    Text("주기")
                        .font(DesignTokens.Typography.rowTitle)
                        .foregroundStyle(DesignTokens.Palette.text)

                    Spacer(minLength: DesignTokens.Metrics.screenPaddingH)

                    Picker("주기", selection: $cycle) {
                        Text(BillingCycle.month.label).tag(BillingCycle.month)
                        Text(BillingCycle.year.label).tag(BillingCycle.year)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(width: 160)
                }

                DatePicker(
                    "다음 결제일",
                    selection: $nextPaymentDate,
                    displayedComponents: .date
                )
                .font(DesignTokens.Typography.rowTitle)
                .foregroundStyle(DesignTokens.Palette.text)
            }

            Section {
                Button {
                    isDeleteAlertPresented = true
                } label: {
                    Text("삭제")
                        .font(DesignTokens.Typography.rowTitle)
                        .foregroundStyle(DesignTokens.Palette.destructive)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("저장") {
                    save()
                }
                .tint(DesignTokens.Palette.accent)
                .disabled(!isValid)
            }
        }
        .alert("이 구독을 삭제할까요?", isPresented: $isDeleteAlertPresented) {
            Button("삭제", role: .destructive) {
                delete()
            }
            Button("취소", role: .cancel) {}
        }
    }

    private func save() {
        guard isValid else { return }

        subscription.name = trimmedName
        subscription.amount = amount
        subscription.cycle = cycle
        subscription.nextPaymentDate = Calendar.current.startOfDay(for: nextPaymentDate)
        dismiss()
    }

    private func delete() {
        modelContext.delete(subscription)
        dismiss()
    }
}

#if DEBUG
private struct SubscriptionDetailPreview: View {
    let cycle: BillingCycle
    @Query private var subscriptions: [Subscription]

    var body: some View {
        NavigationStack {
            if let subscription = subscriptions.first(where: { $0.cycle == cycle }) {
                SubscriptionDetailView(subscription: subscription)
            }
        }
    }
}

#Preview("매달 구독") {
    SubscriptionDetailPreview(cycle: .month)
        .modelContainer(PreviewData.container(with: PreviewData.samples()))
        .preferredColorScheme(.light)
        .dynamicTypeSize(.large)
}

#Preview("매년 구독") {
    SubscriptionDetailPreview(cycle: .year)
        .modelContainer(PreviewData.container(with: PreviewData.samples()))
        .preferredColorScheme(.light)
        .dynamicTypeSize(.large)
}
#endif
