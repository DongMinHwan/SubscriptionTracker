//
//  SettingsView.swift
//  SubscriptionTracker
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(NotificationSettings.isEnabledKey) private var isEnabled = false
    @AppStorage(NotificationSettings.minuteOfDayKey) private var minuteOfDay = NotificationSettings.defaultMinuteOfDay

    /// iOS 설정에서 알림을 꺼 두면 스위치만 켜져 있고 알림은 오지 않는다. 그 상태를 알려 준다.
    @State private var isDenied = false

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    }

    private var alarmTime: Binding<Date> {
        Binding {
            var components = DateComponents()
            components.hour = minuteOfDay / 60
            components.minute = minuteOfDay % 60
            return Calendar.current.date(from: components) ?? .now
        } set: { newValue in
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            minuteOfDay = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("알림 받기", isOn: $isEnabled)
                        .font(DesignTokens.Typography.rowTitle)
                        .foregroundStyle(DesignTokens.Palette.text)
                        .tint(DesignTokens.Palette.accent)

                    if isEnabled {
                        DatePicker(
                            "알림 시각",
                            selection: alarmTime,
                            displayedComponents: .hourAndMinute
                        )
                        .font(DesignTokens.Typography.rowTitle)
                        .foregroundStyle(DesignTokens.Palette.text)
                    }
                } header: {
                    Text("알림")
                } footer: {
                    if isEnabled && isDenied {
                        deniedNotice
                    } else {
                        // 시각만 있으면 그날 아침인지 전날인지 알 수 없다.
                        Text("결제일 하루 전에 알려드립니다.")
                    }
                }

                Section("정보") {
                    LabeledContent("버전", value: appVersion)
                        .font(DesignTokens.Typography.rowTitle)
                        .foregroundStyle(DesignTokens.Palette.text)
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await refreshAuthorizationState() }
        .onChange(of: scenePhase) { _, phase in
            // iOS 설정에서 알림을 허용하고 돌아왔을 수 있다.
            if phase == .active {
                Task { await refreshAuthorizationState() }
            }
        }
        .onChange(of: isEnabled) { _, turnedOn in
            Task { await apply(turnedOn: turnedOn) }
        }
        .onChange(of: minuteOfDay) { _, _ in
            PaymentNotifications.reschedule(from: modelContext)
        }
    }

    private var deniedNotice: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("iOS 설정에서 알림을 허용해야 받을 수 있습니다.")
                .foregroundStyle(DesignTokens.Palette.destructive)

            Button("설정 열기") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
            .tint(DesignTokens.Palette.accent)
        }
    }

    /// 권한은 앱을 처음 켤 때가 아니라 여기서 묻는다. 무엇에 쓰는지 아는 상태로 물어야 한다.
    private func apply(turnedOn: Bool) async {
        guard turnedOn else {
            PaymentNotifications.cancelAll()
            isDenied = false
            return
        }

        if await PaymentNotifications.isAuthorized() {
            isDenied = false
        } else {
            isDenied = await PaymentNotifications.requestAuthorization() == false
        }

        PaymentNotifications.reschedule(from: modelContext)
    }

    private func refreshAuthorizationState() async {
        guard isEnabled else {
            isDenied = false
            return
        }
        isDenied = await PaymentNotifications.isAuthorized() == false
    }
}

#if DEBUG
#Preview {
    SettingsView()
        .modelContainer(PreviewData.container(with: PreviewData.samples()))
        .preferredColorScheme(.light)
        .dynamicTypeSize(.large)
}
#endif
