import Foundation
import WidgetKit

/// App Group 공유 저장소. 앱·위젯·App Intents 어디서든 동일한 데이터를 읽고 쓴다.
/// UserDefaults 대신 App Group 파일을 쓰면 위젯/인텐트 간 동기화가 더 안정적이다.
final class TodoStore {
    static let appGroupID = "group.com.bigtodo.shared"
    static let widgetKind = "TodoLockWidget"
    static let shared = TodoStore()

    private let fileName = "todos.json"
    private let legacyItemsKey = "todo.items.v1"

    /// App Group 컨테이너가 잡혔는지. false면 위젯/잠금화면과 데이터가 안 맞을 수 있다.
    var isAppGroupAvailable: Bool {
        containerURL != nil
    }

    private var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID)
    }

    private var fileURL: URL? {
        containerURL?.appendingPathComponent(fileName)
    }

    // MARK: - 읽기/쓰기

    func load() -> [TodoItem] {
        if let url = fileURL,
           FileManager.default.fileExists(atPath: url.path),
           let data = try? Data(contentsOf: url),
           let items = try? JSONDecoder().decode([TodoItem].self, from: data) {
            return items
        }
        return migrateLegacyDataIfNeeded()
    }

    func save(_ items: [TodoItem]) {
        guard let url = fileURL,
              let data = try? JSONEncoder().encode(items) else { return }
        do {
            try data.write(to: url, options: [.atomic])
        } catch {
            // App Group 미설정 시 조용히 실패 — 앱에서 isAppGroupAvailable로 안내
        }
    }

    private func migrateLegacyDataIfNeeded() -> [TodoItem] {
        guard let defaults = UserDefaults(suiteName: Self.appGroupID),
              let data = defaults.data(forKey: legacyItemsKey),
              let items = try? JSONDecoder().decode([TodoItem].self, from: data) else {
            return []
        }
        save(items)
        defaults.removeObject(forKey: legacyItemsKey)
        return items
    }

    // MARK: - 변경 작업

    @discardableResult
    func add(_ text: String) -> TodoItem {
        var items = load()
        let item = TodoItem(text: text.trimmingCharacters(in: .whitespacesAndNewlines))
        items.insert(item, at: 0)
        save(items)
        return item
    }

    func remove(id: UUID) {
        var items = load()
        items.removeAll { $0.id == id }
        save(items)
    }

    func clearCompleted() {
        var items = load()
        items.removeAll { $0.isDone }
        save(items)
    }

    // MARK: - 파생 정보

    var pending: [TodoItem] {
        load().filter { !$0.isDone }
    }

    var pendingCount: Int { load().count }

    /// 위젯/Live Activity에 변경을 즉시 반영한다.
    func notifyAllViews() {
        WidgetCenter.shared.reloadTimelines(ofKind: Self.widgetKind)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
