//  トップページ（予定一覧画面）
//  ContentView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

struct TopView: View {
    @Environment(\.modelContext) private var modelContext // ModelContextは必要

    // ② @QueryでPlanを取得 (ViewModelは不要に)
    @Query(sort: [SortDescriptor(\Plan.startDate, order: .forward)]) // 開始日でソートする例
    private var plans: [Plan]

    // ③ フィルターの状態をView自身が@Stateで持つ
    @State private var currentFilter: PlanFilter = .upcoming

    // ④ 新規作成シート表示用のフラグ
    @State private var showingNewPlanSheet = false

    // デバッグ用フラグ
    @State private var showDebugAlert = false

    // ⑤ (変更なし) フィルターされたリストを計算
    private var upcomingPlans: [Plan] {
        let now = Date()
        // @Queryの結果である plans を直接フィルター
        return plans.filter { $0.endDate >= now }
           // .sorted { $0.startDate < $1.startDate } // @Queryでソート済みなら不要かも
    }

    private var pastPlans: [Plan] {
        let now = Date()
        return plans.filter { $0.endDate < now }
           // .sorted { $0.endDate > $1.endDate } // 必要ならソート
    }

    // ⑥ (変更なし) 表示用リスト
    private var displayedPlans: [Plan] {
        switch currentFilter {
        case .upcoming:
            return upcomingPlans
        case .past:
            return pastPlans
        }
    }

    // ⑦ (変更なし) initは不要になる (ViewModelを初期化しないため)
    // init(modelContext: ModelContext) { ... } <- 不要

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ⑧ Pickerのバインディングを @State の currentFilter に変更
                Picker("フィルター", selection: $currentFilter) {
                    // PlanFilter.allCases を使って動的に生成 (rawValueを使用)
                    ForEach(PlanFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                // .onChange は不要 (バインディングで直接状態が変わるため)

                // ⑨ エラー/ローディング表示 (シンプル化)
                // @Queryがロード中/エラーの状態を持つわけではないので、
                // 基本的に表示リストの有無で判断する。
                // もし削除時などにエラーを表示したい場合は別途@State変数を用意する
                if displayedPlans.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "map")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                        Text(currentFilter == .upcoming ? "これからの予定はありません" : "過去の予定はありません")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Button {
                            showingNewPlanSheet = true
                        } label: {
                            Text("新しい旅行プランを作成")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    Spacer()
                } else {
                    // ⑩ リスト表示 (変更なし、displayedPlansを使う)
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(displayedPlans) { plan in
                                PlanCardView(plan: plan)
                                    .background(
                                        NavigationLink(value: plan) { EmptyView() }
                                            .opacity(0)
                                    )
                                    .contentShape(Rectangle())
                                    .contextMenu {
                                        // ⑪ 削除処理をView内で直接実行
                                        Button(role: .destructive) {
                                            deletePlan(plan: plan) // ← View内のメソッド呼び出しに変更
                                        } label: {
                                            Label("削除", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("わくわく旅しおり")
            .toolbar { /* ツールバーは変更なし */
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingNewPlanSheet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.blue)
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink { SettingsView() } label: {
                        Image(systemName: "gear").foregroundColor(.gray)
                    }
                }

                // デバッグ用ツールバーアイテムを追加
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        printAllPlans()
                        showDebugAlert = true
                    } label: {
                        Image(systemName: "ladybug.fill")
                            .foregroundColor(.red)
                    }
                }
            }
//            .navigationDestination(for: Plan.self) { plan in
//                PlanDetailContainerView(plan: plan)
//            }
            // ⑫ シート表示: PlanCreateView を直接表示
            .sheet(isPresented: $showingNewPlanSheet) {
                // シート表示時に PlanCreateViewModel を初期化して PlanCreateView に渡す
                // PlanCreateView が modelContext を必要とする場合は渡す
                NavigationStack { // シート内でNavigationを使いたい場合
                    PlanCreateView()
                    // PlanCreateView が ViewModel を必要とするならここで注入
                    // .environment(PlanCreateViewModel(modelContext: modelContext))
                    // または @StateObject で PlanCreateView 自身に持たせる
                }
            }
            // ⑬ .onAppear やシートの onDismiss での fetchPlans 呼び出しは不要
            .alert("デバッグ情報", isPresented: $showDebugAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("コンソールにすべての旅行プラン情報を出力しました")
            }
        }
    }

    // ⑭ 削除メソッドをTopView内に定義
    private func deletePlan(plan: Plan) {
        withAnimation { // アニメーションはお好みで
            modelContext.delete(plan)
            // SwiftData + @Queryなら通常 save() は不要 (自動保存されることが多い)
            // 必要であれば modelContext.save() を呼ぶ
            // do { try modelContext.save() } catch { print(error) }
        }
    }

    // デバッグ用メソッド - すべてのプランをコンソールに出力
    private func printAllPlans() {
        print("=== デバッグ: 保存されているプラン一覧 (合計: \(plans.count)件) ===")

        for (index, plan) in plans.enumerated() {
            print("\n📝 プラン[\(index+1)]: \(plan.title)")
            print("  🗓️ 期間: \(formatDate(plan.startDate)) 〜 \(formatDate(plan.endDate)) (\(plan.totalDays)日間)")
            print("  🎨 テーマ: \(plan.themeName)")
            if let budget = plan.budget {
                print("  💰 予算: ¥\(Int(budget))")
                if let percentage = plan.budgetUsagePercentage {
                    print("  💸 予算使用率: \(String(format: "%.1f", percentage))%")
                }
            }
            if let memo = plan.memo, !memo.isEmpty {
                print("  📝 メモ: \(memo)")
            }

            // スケジュール情報を表示
            print("  📅 スケジュール (\(plan.schedules.count)日):")
            for (scheduleIndex, schedule) in plan.schedules.enumerated() {
                print("    📆 \(scheduleIndex+1)日目 (\(formatDate(schedule.date)))")
                if let title = schedule.title, !title.isEmpty {
                    print("      📌 タイトル: \(title)")
                }

                // PlanItemsの表示
                if let items = schedule.items, !items.isEmpty {
                    print("      🗒️ イベント (\(items.count)件):")
                    for item in schedule.sortedItems {
                        print("        ⏰ \(formatTime(item.time)): \(item.name) (\(item.category))")
                        if let cost = item.cost, cost > 0 {
                            print("          💴 費用: ¥\(Int(cost))")
                        }
                        if let memo = item.memo, !memo.isEmpty {
                            print("          📝 メモ: \(memo)")
                        }
                        if let address = item.address, !address.isEmpty {
                            print("          📍 住所: \(address)")
                        }
                    }
                } else {
                    print("      📭 イベントなし")
                }

                if let notes = schedule.notes, !notes.isEmpty {
                    print("      📝 日程メモ: \(notes)")
                }
            }

            print("  ⏱️ 作成日時: \(formatDateTime(plan.createdAt))")
            print("  ⏱️ 更新日時: \(formatDateTime(plan.updatedAt))")
            print("  🔄 共有状態: \(plan.isShared ? "共有中" : "非共有")")
            if let memberIds = plan.memberIds, !memberIds.isEmpty {
                print("  👥 メンバー: \(memberIds.joined(separator: ", "))")
            }

            print("------------------------")
        }

        print("=== デバッグ出力終了 ===\n")
    }

    // 日付フォーマット用のヘルパーメソッド
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    // 時刻フォーマット用のヘルパーメソッド
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    // 日時フォーマット用のヘルパーメソッド
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

enum PlanFilter: String, CaseIterable { // CaseIterableを追加するとPickerで便利
    case upcoming = "これからの予定"
    case past = "過去の予定"
}
