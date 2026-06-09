import AppIntents

/// 단축어 앱과 Siri에 자동으로 노출되는 기본 단축어 모음.
struct TodoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTodoIntent(),
            phrases: [
                "\(.applicationName)에 할 일 추가",
                "\(.applicationName) 할 일"
            ],
            shortTitle: "할 일 추가",
            systemImageName: "checklist"
        )
        AppShortcut(
            intent: ClearAllIntent(),
            phrases: [
                "\(.applicationName) 모두 비우기"
            ],
            shortTitle: "모두 비우기",
            systemImageName: "trash"
        )
    }
}
