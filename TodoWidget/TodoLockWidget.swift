import SwiftUI
import WidgetKit

struct TodoEntry: TimelineEntry {
    let date: Date
    let items: [TodoItem]
    var pendingCount: Int { items.filter { !$0.isDone }.count }
    var pending: [TodoItem] { items.filter { !$0.isDone } }
}

struct TodoProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(date: Date(), items: [
            TodoItem(text: "우유 사기"),
            TodoItem(text: "운동 30분")
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> Void) {
        completion(TodoEntry(date: Date(), items: TodoStore.shared.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> Void) {
        let entry = TodoEntry(date: Date(), items: TodoStore.shared.load())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

/// 홈/잠금화면 위젯. 남은 할 일을 큼직하게 보여주고, 큰 위젯에서는 바로 체크할 수 있다.
struct TodoLockWidget: Widget {
    let kind = TodoStore.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoProvider()) { entry in
            TodoWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("할 일")
        .description("남은 할 일을 큼직하게 보여줍니다.")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge,
            .accessoryRectangular, .accessoryInline, .accessoryCircular
        ])
    }
}

struct TodoWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TodoEntry

    @ViewBuilder
    var body: some View {
        if entry.items.isEmpty {
            Color.clear
        } else {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryInline:
            Text("할 일 \(entry.pendingCount)개")
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Image(systemName: "checklist")
                        .font(.caption)
                    Text("\(entry.pendingCount)")
                        .font(.title2.bold())
                }
            }
        case .accessoryRectangular:
            rectangularAccessory
        case .systemSmall:
            smallView
        default:
            mediumLargeView
        }
    }

    private var rectangularAccessory: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("남은 \(entry.pendingCount)개", systemImage: "checklist")
                .font(.caption.bold())
            ForEach(entry.pending.prefix(2)) { item in
                Text("• \(item.text)")
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "checklist")
                .font(.title3)
                .foregroundStyle(.tint)
            Text("\(entry.pendingCount)")
                .font(.system(size: 44, weight: .bold))
            Text(entry.pendingCount == 0 ? "모두 완료" : "남은 할 일")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var mediumLargeView: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !entry.items.isEmpty {
                Text("\(entry.pendingCount)개")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            if entry.items.isEmpty {
                Spacer()
                Text("할 일이 없어요 🎉")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ForEach(displayedItems) { item in
                    HStack(spacing: 10) {
                        Button(intent: CompleteTodoIntent(id: item.id)) {
                            Image(systemName: "circle")
                                .font(.title3)
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        Text(item.text)
                            .font(.body.weight(.medium))
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                    .invalidatableContent()
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var displayedItems: [TodoItem] {
        let limit = family == .systemLarge ? 7 : 3
        return Array(entry.items.prefix(limit))
    }
}
