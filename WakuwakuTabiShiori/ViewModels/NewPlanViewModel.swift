//
//  NewPlanViewModel.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

@Observable
class NewPlanViewModel {
    // --- 状態 ---
    var title: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var selectedThemeName: String = "Default" // デフォルトテーマ
    var budgetString: String = "" // 予算は文字列で受け取る
    var errorMessage: String? = nil // エラーメッセージ表示用

    // --- ロジック ---
    func savePlan(context: ModelContext) -> Bool { // 保存成功/失敗を返す
        errorMessage = nil // エラーメッセージをリセット

        // 1. 入力値のバリデーション (チェック)
        guard !title.isEmpty else {
            errorMessage = "タイトルを入力してください。"
            return false
        }
        guard endDate >= startDate else {
            errorMessage = "終了日は開始日以降に設定してください。"
            return false
        }

        // 2. 予算文字列をDouble?に変換 (任意入力なので失敗してもOK)
        let budgetValue = Double(budgetString.filter("0123456789.".contains)) // 数字と小数点のみ抽出して変換

        // 3. 新しいPlanオブジェクトを作成
        let newPlan = Plan(
            title: title,
            startDate: startDate,
            endDate: endDate,
            themeName: selectedThemeName,
            budget: budgetValue,
            createdAt: Date()
        )

        // 4. SwiftDataに保存
        context.insert(newPlan)
        print("New Plan Saved!: \(newPlan.title)")
        // 保存後の処理 (例: CloudKit同期トリガーなど)

        return true // 保存成功
    }
}
