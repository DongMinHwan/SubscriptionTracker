//
//  RootView.swift
//  SubscriptionTracker
//

import SwiftUI
import SwiftData

struct RootView: View {
    #if DEBUG
    @State private var selectedTab = ScreenshotLaunch.settings ? 1 : 0
    #endif

    var body: some View {
        #if DEBUG
        TabView(selection: $selectedTab) {
            Tab("구독", systemImage: "list.bullet", value: 0) {
                SubscriptionListView()
            }

            Tab("설정", systemImage: "gearshape", value: 1) {
                SettingsView()
            }
        }
        .tint(DesignTokens.Palette.accent)
        #else
        TabView {
            Tab("구독", systemImage: "list.bullet") {
                SubscriptionListView()
            }

            Tab("설정", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .tint(DesignTokens.Palette.accent)
        #endif
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
