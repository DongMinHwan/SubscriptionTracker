//
//  SubscriptionStore.swift
//  SubscriptionTracker
//

import Foundation
import SwiftData

/// 앱과 위젯은 서로 다른 프로세스라, 각자 기본 위치에 저장소를 만들면 상대의 데이터를 볼 수 없다.
/// App Group 컨테이너에 저장소를 두어 두 프로세스가 같은 파일을 읽게 한다.
enum SubscriptionStore {
    static let appGroupID = "group.com.dm.SubscriptionTracker"

    static func makeContainer() -> ModelContainer {
        let schema = Schema([Subscription.self])
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(appGroupID)
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("ModelContainer를 만들지 못했습니다: \(error)")
        }
    }
}
