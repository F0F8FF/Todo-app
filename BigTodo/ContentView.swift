import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var vm: TodoViewModel
    @State private var newText: String = ""
    @State private var showSetup = false
    @FocusState private var inputFocused: Bool

    private var store: TodoStore { TodoStore.shared }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !store.isAppGroupAvailable {
                    setupBanner(
                        title: "위젯 연동 안 됨",
                        message: "Xcode에서 본인 Apple 계정(팀)으로 서명 후 다시 설치해 주세요.",
                        actionTitle: "설정 방법"
                    )
                } else if LiveActivityController.needsForegroundStart {
                    setupBanner(
                        title: "잠금화면 표시 대기 중",
                        message: "할 일은 저장됐어요. 앱을 한 번 열면 잠금화면에 뜹니다.",
                        actionTitle: nil
                    )
                }

                inputBar
                if vm.items.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Todo")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSetup = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            LiveActivityController.startIfPossible()
                        } label: {
                            Label("잠금화면에 띄우기", systemImage: "lock.iphone")
                        }
                        Button {
                            LiveActivityController.end()
                        } label: {
                            Label("잠금화면에서 내리기", systemImage: "xmark.circle")
                        }
                        if !vm.items.isEmpty {
                            Divider()
                            Button(role: .destructive) {
                                vm.clearAll()
                            } label: {
                                Label("모두 비우기", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showSetup) {
                SetupGuideView()
            }
            .onAppear {
                LiveActivityController.sync()
            }
        }
    }

    private func setupBanner(title: String, message: String, actionTitle: String?) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.bold())
                Text(message).font(.caption).foregroundStyle(.secondary)
                if let actionTitle {
                    Button(actionTitle) { showSetup = true }
                        .font(.caption.bold())
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.orange.opacity(0.12))
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("할 일을 입력하세요", text: $newText)
                .textFieldStyle(.plain)
                .font(.title3)
                .focused($inputFocused)
                .submitLabel(.done)
                .onSubmit(addCurrent)
            Button(action: addCurrent) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 34))
            }
            .disabled(newText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.thinMaterial)
    }

    private var list: some View {
        List {
            Section {
                ForEach(vm.items) { item in
                    TodoRow(item: item) { vm.complete(item) }
                }
                .onDelete(perform: vm.remove)
            } header: {
                Text("남은 할 일 \(vm.pendingCount)개")
                    .font(.footnote)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "checklist")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("할 일이 없어요")
                .font(.title2.bold())
            Text("위에서 직접 추가하거나\n등 두드리기 단축어로 보내보세요")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("잠금화면 설정 방법") { showSetup = true }
                .font(.subheadline.bold())
                .padding(.top, 8)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func addCurrent() {
        vm.add(newText)
        newText = ""
        inputFocused = false
    }
}

private struct TodoRow: View {
    let item: TodoItem
    let onComplete: () -> Void

    var body: some View {
        Button(action: onComplete) {
            HStack(spacing: 14) {
                Image(systemName: "circle")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.accentColor)
                Text(item.text)
                    .font(.title3)
                Spacer()
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoViewModel())
}

private struct SetupGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("잠금화면에 띄우기 (최초 1회)") {
                    Text("1. 잠금화면 길게 누르기 → **사용자화**")
                    Text("2. **위젯 추가** → **Todo** → **중형/대형** 선택")
                    Text("3. Todo 앱을 **한 번** 실행 (Live Activity 시작)")
                    Text("4. 등 두드리기에 '할 일 적기' 단축어 연결")
                }
                Section("동작 방식") {
                    Text("등 두드리기 → 입력 → 확인 → 잠금화면 위젯/Live Activity에 표시")
                    Text("동그라미 누르면 바로 삭제")
                    Text("할 일 0개면 잠금화면에 아무것도 안 보임")
                }
            }
            .navigationTitle("설정 방법")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}
