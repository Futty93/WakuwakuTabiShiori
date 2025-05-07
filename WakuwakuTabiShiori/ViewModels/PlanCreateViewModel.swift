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
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addPlan() {
        guard !title.isEmpty else { return }
        
        let plan = Plan(
            title: title,
            startDate: startDate,
            endDate: endDate,
            themeName: themeName,
//            themeColor: themeColor,
            budget: budget ?? 0,
            memo: memo
        )
        
        modelContext.insert(plan)
        
        do {
            try modelContext.save()
            
        } catch {
            print("Failed to save changes: \(error)")
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
        budget = 0
        memo = ""
    }
}
