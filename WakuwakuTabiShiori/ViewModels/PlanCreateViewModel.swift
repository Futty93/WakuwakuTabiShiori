//
//  PlanCreateViewModel.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

class PlanCreateViewModel: ObservableObject {
    private var modelContext: ModelContext

    @Published var title: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(24 * 60 * 60)
    @Published var themeName: String = "Default"
    @Published var themeColor: Color = Color.orange
    @Published var budget: Double?
    @Published var memo: String = ""

    // バリデーションエラー用
    @Published var validationError: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // 環境から取得したModelContextに置き換える
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
    }

    func addPlan() -> Bool {
        // バリデーション
        if title.isEmpty {
            validationError = "タイトルを入力してください"
            return false
        }

        if endDate < startDate {
            validationError = "終了日は開始日以降に設定してください"
            return false
        }

        // バリデーションエラーをクリア
        validationError = nil

        // テーマカラーをDataに変換
        let themeColorData = themeColor.toData()

        let plan = Plan(
            title: title,
            startDate: startDate,
            endDate: endDate,
            themeName: themeName,
            themeColorData: themeColorData,
            budget: budget,
            memo: memo.isEmpty ? nil : memo
        )

        modelContext.insert(plan)

        do {
            try modelContext.save()
            return true
        } catch {
            print("Failed to save changes: \(error)")
            validationError = "保存に失敗しました: \(error.localizedDescription)"
            return false
        }
    }

    func deletePlan(_ plan: Plan) {
        modelContext.delete(plan)

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete plan: \(error)")
        }
    }

    // 日数を計算
    var dayCount: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return max(1, (components.day ?? 0) + 1)
    }

    private func resetNewPlanForm() {
        title = ""
        startDate = Date()
        endDate = Date().addingTimeInterval(24 * 60 * 60)
        themeName = "Default"
        themeColor = Color.orange
        budget = nil
        memo = ""
        validationError = nil
    }
}
