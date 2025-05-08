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

        // 新規Planの作成
        let newPlan = Plan(
            title: title,
            startDate: startDate,
            endDate: endDate,
            themeName: themeName,
            themeColorData: themeColor.toData(),
            budget: budget,
            memo: memo.isEmpty ? nil : memo,
            createdAt: Date()
        )

        // 日程ごとのScheduleを作成
        let calendar = Calendar.current
        var currentDate = startDate
        var dayCount = 1

        while currentDate <= endDate {
            let schedule = Schedule(
                date: currentDate,
                title: "\(dayCount)日目",
                createdAt: Date()
            )
            newPlan.schedules.append(schedule)

            // 次の日へ
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            dayCount += 1
        }

        // モデルコンテキストに追加
        modelContext.insert(newPlan)

        // 保存
        do {
            try modelContext.save()
            return true
        } catch {
            print("Error saving plan: \(error)")
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

    // 
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
