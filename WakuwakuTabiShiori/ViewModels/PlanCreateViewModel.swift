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
    // 編集中のプラン（新規作成時はnil）
    private var existingPlan: Plan?

    @Published var title: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(24 * 60 * 60)
    @Published var themeName: String = "Default"
    @Published var themeColor: Color = Color.orange
    @Published var budget: Double?
    @Published var memo: String = ""
    @Published var timeZoneIdentifier: String = "Asia/Tokyo"

    // バリデーションエラー用
    @Published var validationError: String?

    init(modelContext: ModelContext, existingPlan: Plan? = nil) {
        self.modelContext = modelContext
        self.existingPlan = existingPlan

        // 既存のプランがある場合は、そのデータを反映
        if let plan = existingPlan {
            self.title = plan.title
            self.startDate = plan.startDate
            self.endDate = plan.endDate
            self.themeName = plan.themeName
            self.themeColor = plan.themeColor
            self.budget = plan.budget
            self.memo = plan.memo ?? ""
            self.timeZoneIdentifier = plan.timeZoneIdentifier
        }
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

        // 既存のプランが存在する場合は更新
        if let plan = existingPlan {
            return updateExistingPlan(plan)
        } else {
            // 新規作成
            return createNewPlan()
        }
    }

    // 既存のプランを更新
    private func updateExistingPlan(_ plan: Plan) -> Bool {
        // プロパティを更新
        plan.title = title
        plan.startDate = startDate
        plan.endDate = endDate
        plan.themeName = themeName
        plan.themeColorData = themeColor.toData()
        plan.budget = budget
        plan.memo = memo.isEmpty ? nil : memo
        plan.timeZoneIdentifier = timeZoneIdentifier
        plan.updatedAt = Date()

        // 保存
        do {
            try modelContext.save()
            return true
        } catch {
            print("Error updating plan: \(error)")
            return false
        }
    }

    // 新規プランを作成
    private func createNewPlan() -> Bool {
        // 新規Planの作成
        let newPlan = Plan(
            title: title,
            startDate: startDate,
            endDate: endDate,
            themeName: themeName,
            themeColorData: themeColor.toData(),
            budget: budget,
            memo: memo.isEmpty ? nil : memo,
            timeZoneIdentifier: timeZoneIdentifier,
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
                createdAt: Date(),
                plan: newPlan
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
