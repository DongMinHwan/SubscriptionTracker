//
//  SubscriptionTrackerApp.swift
//  SubscriptionTracker
//
//  Created by 황동민 on 8/17/26.
//

import SwiftUI
import SwiftData

@main
struct SubscriptionTrackerApp: App {
    // 위젯도 같은 저장소를 읽어야 하므로 App Group 컨테이너를 쓴다.
    let sharedModelContainer = SubscriptionStore.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
