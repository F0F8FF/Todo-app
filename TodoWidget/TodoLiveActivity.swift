import SwiftUI
import WidgetKit
import ActivityKit

/// 잠금화면에 할 일을 큼직하게 띄우고, 각 항목을 바로 체크할 수 있는 Live Activity.
struct TodoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TodoActivityAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.25))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("\(context.state.pendingCount)", systemImage: "checklist")
                        .font(.title2.bold())
                        .foregroundStyle(.tint)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(context.state.items.prefix(3)) { item in
                            LiveActivityRow(item: item, big: false)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "checklist")
            } compactTrailing: {
                Text("\(context.state.pendingCount)")
                    .font(.caption.bold())
            } minimal: {
                Text("\(context.state.pendingCount)")
                    .font(.caption2.bold())
            }
            .keylineTint(.accentColor)
        }
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TodoActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !context.state.items.isEmpty {
                Text(statusText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            if !context.state.items.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(context.state.items) { item in
                        LiveActivityRow(item: item, big: true)
                    }
                }
            }
        }
        .padding(16)
    }

    private var statusText: String {
        context.state.pendingCount == 0
            ? "모두 완료"
            : "남은 \(context.state.pendingCount)개"
    }
}

/// 잠금화면에서 바로 체크 가능한 한 줄. 버튼이 App Intent를 호출한다.
private struct LiveActivityRow: View {
    let item: TodoSnapshot
    let big: Bool

    var body: some View {
        HStack(spacing: 12) {
            Button(intent: CompleteTodoIntent(id: item.id)) {
                Image(systemName: "circle")
                    .font(.system(size: big ? 28 : 20))
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)

            Text(item.text)
                .font(big ? .title3.weight(.semibold) : .subheadline)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .invalidatableContent()
    }
}
