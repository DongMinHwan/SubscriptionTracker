#if DEBUG
import Foundation

/// 스토어 스크린샷을 찍을 때만 쓰는 실행 인자. 출시 빌드에는 포함되지 않는다.
enum ScreenshotLaunch {
    static var seed: Bool {
        ProcessInfo.processInfo.arguments.contains("-screenshot-seed")
    }

    static var add: Bool {
        ProcessInfo.processInfo.arguments.contains("-screenshot-add")
    }

    static var settings: Bool {
        ProcessInfo.processInfo.arguments.contains("-screenshot-settings")
    }
}
#endif
