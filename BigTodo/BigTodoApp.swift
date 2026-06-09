import SwiftUI

@main
struct BigTodoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = TodoViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .task {
                    // 단축어/잠금화면 추가 직후 앱이 열리면 Live Activity를 바로 시작
                    viewModel.reload()
                    await LiveActivityController.syncAsync()
                    TodoStore.shared.notifyAllViews()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.reload()
                Task {
                    await LiveActivityController.syncAsync()
                    TodoStore.shared.notifyAllViews()
                }
            }
        }
    }
}
