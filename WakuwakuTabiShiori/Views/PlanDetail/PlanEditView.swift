////  予定全体の編集画面（タイトル、期間など）
////  PlanEditView.swift
////  WakuwakuTabiShiori
////
////  Created by 二渡和輝 on 2025/04/19.
////
//
//import SwiftUI
//import SwiftData
//
//struct PlanEditView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.dismiss) private var dismiss
//
//    @Bindable var plan: Plan
//
//    // 入力用の状態変数
//    @State private var title: String
//    @State private var startDate: Date
//    @State private var endDate: Date
//    @State private var budget: Double?
//    @State private var themeName: String
//    @State private var themeColor: Color
//
//    // 日程管理用
//    @State private var schedules: [Schedule] = []
//    @State private var showingAlert = false
//    @State private var showingDeleteAlert = false
//    @State private var showingThemeSelection = false
//    @State private var showConfirmationDialog = false
//
//    // 日付の最小値と最大値
//    @State private var minEndDate: Date
//
//    // 日付フォーマッター
//    private let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long
//        formatter.timeStyle = .none
//        return formatter
//    }()
//
//    // 初期化
//    init(plan: Plan) {
//        self.plan = plan
//
//        // 初期値をplanから設定
//        _title = State(initialValue: plan.title)
//        _startDate = State(initialValue: plan.startDate)
//        _endDate = State(initialValue: plan.endDate)
//        _budget = State(initialValue: plan.budget)
//        _themeName = State(initialValue: plan.themeName)
//        _themeColor = State(initialValue: plan.themeColor)
//        _minEndDate = State(initialValue: plan.startDate)
//
//        // 日程のコピーを作成
//        if plan.schedules.isEmpty {
//            let schedules: [Schedule] = plan.schedules
//            _schedules = State(initialValue: schedules)
//        }
//    }
//
//    var body: some View {
//        Form {
//            // 基本情報セクション
//            Section {
//                TextField("旅行のタイトル", text: $title)
//                    .font(.headline)
//
//                DatePicker("出発日", selection: $startDate, displayedComponents: .date)
//                    .onChange(of: startDate) { oldValue, newValue in
//                        // startDateが変わったらendDateの最小値も変更
//                        minEndDate = newValue
//
//                        // endDateがstartDateより前なら合わせる
//                        if endDate < newValue {
//                            endDate = newValue
//                        }
//                    }
//
//                DatePicker("帰宅日", selection: $endDate, in: minEndDate..., displayedComponents: .date)
//
//                // テーマ選択
//                HStack {
//                    Text("テーマ")
//                    Spacer()
//                    Text(themeName)
//                        .foregroundColor(.secondary)
//
//                    Circle()
//                        .fill(themeColor)
//                        .frame(width: 20, height: 20)
//                }
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    showingThemeSelection = true
//                }
//            } header: {
//                Text("基本情報")
//                    .foregroundColor(themeColor)
//            }
//
//            // 予算セクション
//            Section {
//                HStack {
//                    Text("¥")
//                    TextField("予算（任意）", value: $budget, format: .number)
//                        .keyboardType(.numberPad)
//                }
//            } header: {
//                Text("予算")
//                    .foregroundColor(themeColor)
//            }
//
//            // 日程リスト
//            Section {
//                if !plan.schedules.isEmpty {
//                    let planSchedules = plan.schedules
//                    ForEach(planSchedules) { schedule in
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text(dateFormatter.string(from: schedule.date))
//                                    .font(.headline)
//
//                                if let title = schedule.title {
//                                    Text(title)
//                                        .font(.subheadline)
//                                        .foregroundColor(.secondary)
//                                }
//                            }
//
//                            Spacer()
//
//                            // 項目数表示
//                            if let items = schedule.items, !items.isEmpty {
//                                Text("\(items.count)個の予定")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                        .padding(.vertical, 4)
//                    }
//                } else {
//                    Text("日程が登録されていません")
//                        .foregroundColor(.secondary)
//                }
//
//                // 日程を再作成するボタン
//                Button {
//                    showConfirmationDialog = true
//                } label: {
//                    Label("日程を再生成", systemImage: "arrow.clockwise")
//                        .foregroundColor(themeColor)
//                }
//            } header: {
//                Text("日程管理")
//                    .foregroundColor(themeColor)
//            } footer: {
//                Text("期間変更時、手動で日程を再生成できます")
//                    .font(.caption)
//            }
//
//            // 削除ボタン
//            Section {
//                Button(role: .destructive) {
//                    showingDeleteAlert = true
//                } label: {
//                    HStack {
//                        Spacer()
//                        Label("旅行プランを削除", systemImage: "trash")
//                        Spacer()
//                    }
//                }
//            }
//
//            // 保存ボタン
//            Section {
//                Button {
//                    saveChanges()
//                } label: {
//                    Text("変更を保存")
//                        .bold()
//                        .frame(maxWidth: .infinity)
//                }
//                .disabled(title.isEmpty)
//                .listRowBackground(title.isEmpty ? Color.gray.opacity(0.3) : themeColor)
//                .foregroundColor(.white)
//            }
//            .listRowInsets(EdgeInsets())
//        }
//        .navigationTitle("プランを編集")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .cancellationAction) {
//                Button("キャンセル") {
//                    dismiss()
//                }
//            }
//        }
////        .sheet(isPresented: $showingThemeSelection) {
////            NavigationStack {
////                ThemeSelectionView(selectedThemeName: $themeName, selectedColor: $themeColor)
////            }
////            .presentationDetents([.medium, .large])
////        }
//        .alert("確認", isPresented: $showConfirmationDialog) {
//            Button("キャンセル", role: .cancel) { }
//            Button("再生成") {
//                regenerateSchedules()
//            }
//        } message: {
//            Text("日程を再生成すると、既存の日程に紐づく予定も全て削除されます。本当に再生成しますか？")
//        }
//        .alert("旅行プランを削除", isPresented: $showingDeleteAlert) {
//            Button("キャンセル", role: .cancel) { }
//            Button("削除", role: .destructive) {
//                deletePlan()
//            }
//        } message: {
//            Text("この旅行プランを削除します。この操作は元に戻せません。")
//        }
//    }
//
//    // 変更を保存
//    private func saveChanges() {
//        plan.title = title
//        plan.startDate = startDate
//        plan.endDate = endDate
//        plan.budget = budget
//        plan.themeName = themeName
//        plan.themeColor = themeColor
//        plan.updatedAt = Date()
//
//        dismiss()
//    }
//
//    // 日程を再生成
//    private func regenerateSchedules() {
//        // 既存の日程と予定を全て削除
//        if plan.schedules.isEmpty {
//            let oldSchedules = plan.schedules
//            for schedule in oldSchedules {
//                if let items = schedule.items {
//                    for item in items {
//                        modelContext.delete(item)
//                    }
//                }
//                modelContext.delete(schedule)
//            }
//        }
//
//        // 新しい日程を作成
//        let calendar = Calendar.current
//        if let dayCount = calendar.dateComponents([.day], from: startDate, to: endDate).day {
//            var newSchedules: [Schedule] = []
//
//            for i in 0...dayCount {
//                if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
//                    let dayNumber = i + 1
//                    let schedule = Schedule(
//                        date: date,
//                        title: "\(dayNumber)日目",
//                        createdAt: Date(),
//                        updatedAt: Date()
//                    )
//                    // リレーションを設定
//                    schedule.plan = plan
//                    newSchedules.append(schedule)
//                }
//            }
//
//            // 日程をセット
//            plan.schedules = newSchedules
//        }
//    }
//
//    // プラン削除
//    private func deletePlan() {
//        modelContext.delete(plan)
//        dismiss()
//    }
//}
//
//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: Plan.self, configurations: config)
//
//    // サンプルデータ作成
//    let plan = Plan(
//        startDate: Date(),
//        endDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
//        themeName: "Sea",
//        budget: 50000,
//        createdAt: Date()
//    )
//
//    NavigationStack {
//        PlanEditView(plan: plan)
//    }
//    .modelContainer(container)
//}
