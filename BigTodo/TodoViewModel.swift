import Foundation
import Combine

/// 메인 앱 UI를 위한 관찰 가능한 뷰모델. 공유 저장소를 감싼다.
@MainActor
final class TodoViewModel: ObservableObject {
    @Published var items: [TodoItem] = []

    private let store = TodoStore.shared

    init() {
        reload()
    }

    func reload() {
        items = store.load()
    }

    func add(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.add(trimmed)
        afterMutation()
    }

    /// 체크 = 완료 = 삭제.
    func complete(_ item: TodoItem) {
        store.remove(id: item.id)
        afterMutation()
    }

    func remove(at offsets: IndexSet) {
        let ids = offsets.map { items[$0].id }
        ids.forEach { store.remove(id: $0) }
        afterMutation()
    }

    func clearAll() {
        store.save([])
        afterMutation()
    }

    var pendingCount: Int { items.count }

    private func afterMutation() {
        reload()
        store.notifyAllViews()
        if items.isEmpty {
            LiveActivityController.refreshOrEnd()
        } else {
            LiveActivityController.sync()
        }
    }
}
