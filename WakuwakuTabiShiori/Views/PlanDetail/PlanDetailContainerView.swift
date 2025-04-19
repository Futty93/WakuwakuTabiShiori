//  表紙・日程リストを管理する親ビュー
//  PlanDetailContainerView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI

struct PlanDetailContainerView: View {
    let plan: Plan
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PlanDetailContainerView(plan: Plan(id: UUID(), title: "群馬旅行", startDate: Date(), endDate: Date(), themeName: "", budget: nil, createdAt: Date()))
}
