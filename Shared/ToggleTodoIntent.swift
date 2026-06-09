import AppIntents
import ActivityKit
import WidgetKit

/// 위젯·Live Activity의 체크 버튼이 호출하는 인텐트.
/// 잠금화면에서 체크를 누르면 해당 할 일을 바로 삭제하고 화면을 즉시 갱신한다.
struct CompleteTodoIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "할 일 완료(삭제)"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "할 일 ID")
    var todoID: String

    init() {}

    init(id: UUID) {
        self.todoID = id.uuidString
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: todoID) else {
            return .result()
        }

        TodoStore.shared.remove(id: uuid)
        await LiveActivityController.refreshOrEndAsync()
        TodoStore.shared.notifyAllViews()

        return .result()
    }
}

/// 모든 할 일을 비우는 인텐트 (단축어/앱 공용).
struct ClearAllIntent: AppIntent {
    static var title: LocalizedStringResource = "할 일 모두 비우기"
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        TodoStore.shared.save([])
        await LiveActivityController.refreshOrEndAsync()
        TodoStore.shared.notifyAllViews()
        return .result(dialog: "할 일을 모두 비웠어요.")
    }
}
