//
//  AddSubscriptionView.swift
//  SubscriptionTracker
//

import SwiftUI
import SwiftData

struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var amountText = ""
    @State private var cycle: BillingCycle = .month
    @State private var nextPaymentDate = Calendar.current.startOfDay(for: .now)

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
        NavigationStack {
            Form {
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
            .navigationTitle("구독 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .tint(DesignTokens.Palette.accent)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        save()
                    }
                    .tint(DesignTokens.Palette.accent)
                    .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        guard isValid else { return }

        let subscription = Subscription(
            name: trimmedName,
            amount: amount,
            cycle: cycle,
            nextPaymentDate: nextPaymentDate
        )
        modelContext.insert(subscription)

        // 앱을 처음 깔면 이미 쓰고 있는 구독부터 넣게 되고, 그때 손에 잡히는 날짜는
        // 기억나는 지난 결제일이다. 여기서 다음 주기로 맞춰 두면 사용자가 "그럼 다음은
        // 몇 월 며칠이지"를 계산하지 않아도 된다.
        subscription.rollForwardIfNeeded()

        modelContext.saveAndRefreshWidgets()
        dismiss()
    }
}

#if DEBUG
#Preview("빈 상태") {
    AddSubscriptionView()
        .modelContainer(PreviewData.container(with: []))
        .preferredColorScheme(.light)
        .dynamicTypeSize(.large)
}

#Preview("구독 여러 개") {
    AddSubscriptionView()
        .modelContainer(PreviewData.container(with: PreviewData.samples()))
        .preferredColorScheme(.light)
        .dynamicTypeSize(.large)
}
#endif
