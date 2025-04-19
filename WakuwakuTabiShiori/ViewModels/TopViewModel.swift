//
//  TopViewModel.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

@Observable // SwiftUIでViewに変更を通知するための仕組み (iOS 17以降 / 以前はObservableObject)
class TopViewModel {
    // --- 状態 (Viewが表示に使うデータ) ---
    @ObservationIgnored // ModelContextはViewの変更通知には不要なので無視
    private var modelContext: ModelContext? // データ操作用 (Viewから渡される)

    var plans: [Plan] = [] // 表示する予定のリスト (最初は空)
    var isLoading: Bool = false // データ読み込み中かどうか
    var currentFilter: PlanFilter = .upcoming // 現在のフィルター (.upcoming or .past)

    enum PlanFilter {
        case upcoming, past
    }

    // --- 初期化 ---
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        fetchPlans() // 初期化時にデータを読み込む
    }

    // --- ロジック (Viewからの指示で実行される処理) ---
    func fetchPlans() {
        guard let context = modelContext else { return }
        isLoading = true // 読み込み開始

        // SwiftDataからデータを取得 (非同期処理が推奨される場合もある)
        do {
            let descriptor = FetchDescriptor<Plan>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let allPlans = try context.fetch(descriptor)

            // フィルターに基づいて表示するプランを決定
            switch currentFilter {
            case .upcoming:
                // startDateが今日以降のものをフィルタリング (日付比較が必要)
                plans = allPlans.filter { $0.startDate >= Date() /* より正確な日付比較を実装 */ }
            case .past:
                // startDateが今日より前のものをフィルタリング
                plans = allPlans.filter { $0.startDate < Date() /* より正確な日付比較を実装 */ }
            }
            print("Fetched \(plans.count) plans for filter: \(currentFilter)")
        } catch {
            print("Failed to fetch plans: \(error)")
            // ここでエラー処理（例: エラーメッセージを保持するプロパティを更新）
        }
        isLoading = false // 読み込み完了
    }

    func deletePlan(plan: Plan) {
        guard let context = modelContext else { return }
        context.delete(plan)
        // 必要に応じて plans 配列からも削除 or 再フェッチ
        fetchPlans() // 削除後にリストを更新
    }

    func setFilter(_ filter: PlanFilter) {
        currentFilter = filter
        fetchPlans() // フィルターが変更されたらデータを再取得
    }
}


