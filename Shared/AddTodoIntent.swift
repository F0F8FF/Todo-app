import AppIntents

/// 단축어(또는 Siri)로 새 할 일을 추가한다.
/// `LiveActivityIntent`를 채택하면 iOS 17.2+에서 앱을 열지 않고
/// 백그라운드(잠금화면)에서도 Live Activity를 시작할 수 있다.
struct AddTodoIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "할 일 추가"
    static var description = IntentDescription("새 할 일을 추가하고 잠금화면에 큼직하게 띄웁니다.")

    /// false: 잠금화면에서 추가해도 앱 창이 안 뜸.
    static var openAppWhenRun: Bool = false

    @Parameter(
        title: "할 일",
        description: "추가할 할 일 내용",
        requestValueDialog: "할 일 추가"
    )
    var text: String

    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$text) 추가하기")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .result()
        }

        TodoStore.shared.add(trimmed)
        await LiveActivityController.syncAsync()
        TodoStore.shared.notifyAllViews()

        return .result()
    }
}
