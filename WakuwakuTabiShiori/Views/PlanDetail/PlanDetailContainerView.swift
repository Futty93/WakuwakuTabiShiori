//  表紙・日程リストを管理する親ビュー
//  PlanDetailContainerView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

struct PlanDetailContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var plan: Plan

    // 選択中のタブ
    @State private var selectedTab: DetailTab = .cover
    @State private var showingEditSheet = false

    enum DetailTab {
        case cover, schedule
    }

    var body: some View {
        VStack(spacing: 0) {
            // カスタムタブビュー
            HStack(spacing: 0) {
                tabButton(text: "表紙", tab: .cover)
                tabButton(text: "日程表", tab: .schedule)
            }
            .background(
                // タブ下部の線
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
            )

            // タブコンテンツ
            TabView(selection: $selectedTab) {
                PlanDetailCoverView(plan: plan)
                    .tag(DetailTab.cover)

                PlanDetailScheduleListView(plan: plan)
                    .tag(DetailTab.schedule)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
        }
        .navigationTitle(plan.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                PlanEditView(plan: plan)
            }
        }
        .background(Color(.systemBackground))
    }

    // タブボタン
    private func tabButton(text: String, tab: DetailTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 8) {
                Text(text)
                    .font(.headline)
                    .foregroundColor(selectedTab == tab ? plan.themeColor : .gray)
                    .frame(maxWidth: .infinity)

                // 選択インジケーター
                Rectangle()
                    .fill(selectedTab == tab ? plan.themeColor : Color.clear)
                    .frame(height: 3)
            }
            .padding(.top, 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Plan.self, configurations: config)

    let plan = Plan(id: UUID(), title: "群馬旅行", startDate: Date(), endDate: Date(), themeName: "Default", budget: 30000, createdAt: Date())

    return NavigationStack {
        PlanDetailContainerView(plan: plan)
    }
    .modelContainer(container)
}
