import Foundation
import ActivityKit

/// Live Activity에 전달되는 한 줄 스냅샷.
struct TodoSnapshot: Codable, Hashable, Identifiable {
    var id: UUID
    var text: String
    var isDone: Bool
}

/// 잠금화면 Live Activity의 속성 정의.
/// `ContentState`는 수시로 바뀌는 동적 데이터, 그 외 필드는 고정 데이터.
struct TodoActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// 잠금화면에 큼직하게 띄울 할 일들 (완료 포함, 최대 표시 개수 제한).
        var items: [TodoSnapshot]
        /// 남은(미완료) 할 일 개수.
        var pendingCount: Int
        /// 전체 할 일 개수.
        var totalCount: Int
    }

    /// Live Activity 상단 제목.
    var title: String
}
