//
//  RootView.swift
//  SubscriptionTracker
//

import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        TabView {
            Tab("구독", systemImage: "list.bullet") {
                SubscriptionListView()
            }

            Tab("설정", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .tint(DesignTokens.Palette.accent)
    }
}

#if DEBUG
#Preview {
    RootView()
        .modelContainer(PreviewData.container(with: PreviewData.samples()))
        .preferredColorScheme(.light)
        .dynamicTypeSize(.large)
}
#endif
