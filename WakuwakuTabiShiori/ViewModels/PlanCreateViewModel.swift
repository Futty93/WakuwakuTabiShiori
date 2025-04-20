//
//  PlanCreateViewModel.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

class PlanCreateViewModel: ObservableObject {
    @Published var title = ""
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(24 * 60 * 60)
    @Published var themeName = "Default"
    @Published var themeColor = Color.orange
    @Published var budget: Double?
    @Published var memo = ""

    var modelContext: ModelContext
    private var plan: Plan?
    var dismissAction: DismissAction?

    init(modelContext: ModelContext, plan: Plan? = nil, dismiss: @escaping () -> Void) {
        self.modelContext = modelContext
        self.plan = plan
        self.dismissAction = dismiss

        // 既存プランの場合は値を設定
        if let plan = plan {
            title = plan.title
            startDate = plan.startDate
            endDate = plan.endDate
            themeName = plan.themeName
            themeColor = plan.themeColor
            budget = plan.budget
            memo = plan.memo ?? ""
        }
    }

    // 日数を計算
    var dayCount: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return max(1, (components.day ?? 0) + 1)
    }

    // 入力バリデーション
    var isFormValid: Bool {
        !title.isEmpty
    }

    // プラン保存処理
    func savePlan() {
        if let plan = plan {
            // 既存プランの更新
            plan.title = title
            plan.startDate = startDate
            plan.endDate = endDate
            plan.themeName = themeName
            plan.themeColor = themeColor
            plan.budget = budget
            plan.memo = memo.isEmpty ? nil : memo
            plan.updatedAt = Date()

            // 日程の更新（日数が変わった場合）
            updateSchedules(for: plan)
        } else {
            // 新規プランの作成
            let newPlan = Plan(
                title: title,
                startDate: startDate,
                endDate: endDate,
                themeName: themeName,
                themeColorData: themeColor.toData(),
                budget: budget,
                memo: memo.isEmpty ? nil : memo,
                createdAt: Date(),
                updatedAt: Date()
            )
            modelContext.insert(newPlan)

            // 日程を生成
            createSchedules(for: newPlan)
        }

        dismissAction()
    }

    // 日程の生成
    private func createSchedules(for plan: Plan) {
        for day in 0..<dayCount {
            guard let date = Calendar.current.date(byAdding: .day, value: day, to: startDate) else { continue }

            let schedule = Schedule(
                date: date,
                title: "\(day + 1)日目",
                createdAt: Date(),
                updatedAt: Date()
            )
            schedule.plan = plan
            plan.schedules?.append(schedule)
        }
    }

    // 日程の更新（日数が変わった場合）
    private func updateSchedules(for plan: Plan) {
        guard let schedules = plan.schedules else { return }

        let currentCount = schedules.count

        if dayCount > currentCount {
            // 日程を追加
            for day in currentCount..<dayCount {
                guard let date = Calendar.current.date(byAdding: .day, value: day, to: startDate) else { continue }

                let schedule = Schedule(
                    date: date,
                    title: "\(day + 1)日目",
                    createdAt: Date(),
                    updatedAt: Date()
                )
                schedule.plan = plan
                plan.schedules?.append(schedule)
            }
        } else if dayCount < currentCount {
            // 日程を削除（最後から）
            let sortedSchedules = schedules.sorted(by: { $0.date < $1.date })
            for index in dayCount..<currentCount {
                if index < sortedSchedules.count {
                    modelContext.delete(sortedSchedules[index])
                }
            }
        }

        // 日付を更新
        let sortedSchedules = schedules.sorted(by: { $0.date < $1.date })
        for (index, schedule) in sortedSchedules.enumerated() {
            if index < dayCount {
                if let date = Calendar.current.date(byAdding: .day, value: index, to: startDate) {
                    schedule.date = date
                }
            }
        }
    }
}
