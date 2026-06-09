import Foundation

/// 하나의 할 일 항목. 앱과 위젯/Live Activity 양쪽에서 공유한다.
struct TodoItem: Codable, Identifiable, Hashable {
    var id: UUID
    var text: String
    var isDone: Bool
    var createdAt: Date

    init(id: UUID = UUID(), text: String, isDone: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.isDone = isDone
        self.createdAt = createdAt
    }
}
