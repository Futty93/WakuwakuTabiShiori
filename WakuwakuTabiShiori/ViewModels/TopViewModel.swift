//
//  TopViewModel.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData


//@Observable // SwiftUIでViewに変更を通知するための仕組み (iOS 17以降 / 以前はObservableObject)
//class TopViewModel {
//    // --- 状態 (Viewが表示に使うデータ) ---
//    @ObservationIgnored // ModelContextはViewの変更通知には不要なので無視
//    private var modelContext: ModelContext? // データ操作用 (Viewから渡される)
//
//    var plans: [Plan] = [] // 表示する予定のリスト (最初は空)
//    var isLoading: Bool = false // データ読み込み中かどうか
//    var currentFilter: PlanFilter = .upcoming // 現在のフィルター (.upcoming or .past)
//    var errorMessage: String? = nil // エラーメッセージ
//
//    enum PlanFilter {
//        case upcoming, past
//    }
//
//    // --- 初期化 ---
//    init(modelContext: ModelContext? = nil) {
//        self.modelContext = modelContext
//        fetchPlans() // 初期化時にデータを読み込む
//    }
//
//    // --- ロジック (Viewからの指示で実行される処理) ---
//    func fetchPlans() {
//        guard let context = modelContext else { return }
//        isLoading = true // 読み込み開始
//        errorMessage = nil
//
//        // SwiftDataからデータを取得
//        do {
//            let descriptor = FetchDescriptor<Plan>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
//            let allPlans = try context.fetch(descriptor)
//
//            // 現在日付の0時0分を取得（時間部分を無視するため）
//            let calendar = Calendar.current
//            let today = calendar.startOfDay(for: Date())
//
//            // フィルターに基づいて表示するプランを決定
//            switch currentFilter {
//            case .upcoming:
//                // endDateが今日以降のものをフィルタリング
//                plans = allPlans.filter { plan in
//                    let endDate = calendar.startOfDay(for: plan.endDate)
//                    return endDate >= today
//                }
//            case .past:
//                // endDateが昨日以前のものをフィルタリング
//                plans = allPlans.filter { plan in
//                    let endDate = calendar.startOfDay(for: plan.endDate)
//                    return endDate < today
//                }
//            }
//
//            print("Fetched \(plans.count) plans for filter: \(currentFilter)")
//        } catch {
//            print("Failed to fetch plans: \(error)")
//            errorMessage = "プランの読み込みに失敗しました: \(error.localizedDescription)"
//        }
//
//        isLoading = false // 読み込み完了
//    }
//
//    func deletePlan(plan: Plan) {
//        guard let context = modelContext else { return }
//
//        do {
//            context.delete(plan)
//            try context.save() // 明示的に保存
//
//            // UIの更新のため、plans配列から削除
//            if let index = plans.firstIndex(where: { $0.id == plan.id }) {
//                plans.remove(at: index)
//            }
//        } catch {
//            print("Failed to delete plan: \(error)")
//            errorMessage = "プランの削除に失敗しました: \(error.localizedDescription)"
//            fetchPlans() // 状態を再同期
//        }
//    }
//
//    func setFilter(_ filter: PlanFilter) {
//        currentFilter = filter
//        fetchPlans() // フィルターが変更されたらデータを再取得
//    }
//
//    // 新規プラン作成後、リストを更新するメソッド
//    func refreshAfterCreate() {
//        fetchPlans()
//    }
//}
//
//
