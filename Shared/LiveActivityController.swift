import Foundation
import ActivityKit

/// 잠금화면 Live Activity의 시작·갱신·종료를 담당한다.
enum LiveActivityController {
    static let maxItems = 4
    static let activityTitle = "Todo"
    private static let pendingStartKey = "liveActivity.pendingStart"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: TodoStore.appGroupID) ?? .standard
    }

    /// 현재 저장된 할 일로 Live Activity의 ContentState를 만든다.
    private static func makeState() -> TodoActivityAttributes.ContentState {
        let pending = TodoStore.shared.load()
        let shown = Array(pending.prefix(maxItems))
        let snapshots = shown.map { TodoSnapshot(id: $0.id, text: $0.text, isDone: $0.isDone) }
        return .init(items: snapshots, pendingCount: pending.count, totalCount: pending.count)
    }

    private static var currentActivity: Activity<TodoActivityAttributes>? {
        Activity<TodoActivityAttributes>.activities.first
    }

    /// 저장소 상태와 Live Activity를 맞춘다. (필요하면 시작, 있으면 갱신)
    static func sync() {
        Task { await syncAsync() }
    }

    @MainActor
    static func syncAsync() async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let state = makeState()

        if state.totalCount == 0 {
            await endAsync()
            defaults.set(false, forKey: pendingStartKey)
            return
        }

        if let activity = currentActivity {
            await activity.update(ActivityContent(state: state, staleDate: nil))
            defaults.set(false, forKey: pendingStartKey)
        } else {
            let started = await startAsync(with: state)
            defaults.set(!started, forKey: pendingStartKey)
        }
    }

    /// 갱신만 시도한다.
    static func update() {
        Task { await updateAsync() }
    }

    @MainActor
    static func updateAsync() async {
        guard let activity = currentActivity else { return }
        let state = makeState()
        await activity.update(ActivityContent(state: state, staleDate: nil))
    }

    /// 체크(삭제) 후 호출. 남은 할 일이 없으면 잠금화면 표시를 정리, 있으면 갱신.
    static func refreshOrEnd() {
        Task { await refreshOrEndAsync() }
    }

    @MainActor
    static func refreshOrEndAsync() async {
        let state = makeState()

        guard let activity = currentActivity else {
            if state.totalCount == 0 {
                defaults.set(false, forKey: pendingStartKey)
            }
            return
        }

        if state.totalCount == 0 {
            await activity.end(nil, dismissalPolicy: .immediate)
            defaults.set(false, forKey: pendingStartKey)
        } else {
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }

    @MainActor
    @discardableResult
    private static func startAsync(with state: TodoActivityAttributes.ContentState) async -> Bool {
        let attributes = TodoActivityAttributes(title: activityTitle)
        do {
            _ = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
            return true
        } catch {
            return false
        }
    }

    /// 명시적으로 시작 (앱 버튼용).
    static func startIfPossible() {
        sync()
    }

    static func end() {
        Task { await endAsync() }
    }

    @MainActor
    static func endAsync() async {
        for activity in Activity<TodoActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    /// 백그라운드에서 Live Activity 시작이 막혔을 때 true.
    static var needsForegroundStart: Bool {
        defaults.bool(forKey: pendingStartKey) && !TodoStore.shared.load().isEmpty
    }
}
