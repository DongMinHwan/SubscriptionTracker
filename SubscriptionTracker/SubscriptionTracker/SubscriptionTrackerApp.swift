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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Subscription.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SubscriptionListView()
                .preferredColorScheme(.light)
                .dynamicTypeSize(.large)
        }
        .modelContainer(sharedModelContainer)
    }
}
