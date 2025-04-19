//  トップページで使う予定カード
//  PlanCardView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI

struct PlanCardView: View {
    let plan: Plan
    var body: some View {
        VStack(alignment: .leading) {
            Text(plan.title).font(.headline)
            Text("\(plan.startDate, style: .date) - \(plan.endDate, style: .date)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        // ここにテーマカラーやカウントダウン表示などを追加
        .padding()
        .background(Color.gray.opacity(0.1)) // 仮の背景
        .cornerRadius(10)
    }
}


#Preview {
    PlanCardView(plan: Plan(id: UUID(), title: "福岡観光", startDate: Date(), endDate: Date(), themeName: "", budget: nil, createdAt: Date()))
}
