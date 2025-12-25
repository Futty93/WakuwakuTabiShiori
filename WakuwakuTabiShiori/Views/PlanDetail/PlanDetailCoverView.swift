//  予定詳細の「表紙」部分
//  PlanDetailCoverView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

struct PlanDetailCoverView: View {
    @Bindable var plan: Plan
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false

    // ViewModel
    @StateObject private var viewModel: PlanDetailViewModel

    init(plan: Plan) {
        self.plan = plan
        // ViewModelの初期化（modelContextはonAppearで環境から取得したものに置き換える）
        // 一時的なModelContextを使用し、初期化エラーを避ける
        let temporaryContext = createTemporaryModelContext(Plan.self)
        self._viewModel = StateObject(wrappedValue: PlanDetailViewModel(
            plan: plan,
            modelContext: temporaryContext
        ))
    }

    // 日付フォーマッター
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ヘッダー背景
                themeBanner

                scheduleShortcut

                // 情報セクション
                infoSection

                // 予算セクション
                if let budget = plan.budget {
                    budgetSection(budget: budget)
                }

                // メモセクション
                if let memo = plan.memo, !memo.isEmpty {
                    memoSection(memo: memo)
                }

            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // ModelContextを更新（@Environmentから取得）
            viewModel.modelContext = modelContext
            // プランへの参照も最新に更新
            viewModel.plan = plan
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(plan.themeColor)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                PlanCreateView(plan: plan)
            }
        }
    }

    // テーマバナー
    private var themeBanner: some View {
        ZStack(alignment: .bottomLeading) {
            // 背景
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [plan.themeColor, plan.themeColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 200)

            // テーマアイコン
            VStack(alignment: .leading) {
                // テーマアイコン（テーマに合わせて変更する）
                Image(systemName: Color.iconNameForTheme(plan.themeName))
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.9))

                // タイトル
                Text(plan.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 1)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    // 情報セクション
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            NavigationLink(destination: PlanDetailScheduleListView(plan: plan)) {
                // 期間
                HStack(alignment: .top) {
                    Image(systemName: "calendar")
                        .foregroundColor(plan.themeColor)
                        .frame(width: 26)

                    VStack(alignment: .leading) {
                        Text("旅行期間")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("\(plan.startDate.formatLongDate()) 〜 \(plan.endDate.formatLongDate())")
                            .font(.headline)

                        Text("\(plan.totalDays)日間")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())

            Divider()

            // テーマ
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(plan.themeColor)
                    .frame(width: 26)

                VStack(alignment: .leading) {
                    Text("テーマ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(plan.themeName)
                        .font(.headline)
                }
            }
        }
        .cardStyle()
    }

    private var scheduleShortcut: some View {
        NavigationLink(destination: PlanDetailScheduleListView(plan: plan)) {
            HStack {
                Image(systemName: "calendar.day.timeline.left")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(plan.themeColor)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("日程リストを開く")
                        .font(.headline)
                    Text("予定の追加・編集はこちら")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // 予算セクション
    private func budgetSection(budget: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("予算")
                .font(.headline)
                .padding(.horizontal)

            HStack(alignment: .top, spacing: 20) {
                // 予算金額
                VStack {
                    Text(budget.formatAsYen())
                        .font(.title2.bold())
                        .foregroundColor(plan.themeColor)

                    Text("目安予算")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                // 使用金額（計算済み）
                if let usedBudget = viewModel.calculateUsedBudget() {
                    VStack {
                        Text(usedBudget.formatAsYen())
                            .font(.title2.bold())
                            .foregroundColor(usedBudget > budget ? .red : .green)

                        Text("使用済み")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                // 残り予算
                if let remainingBudget = viewModel.calculateRemainingBudget() {
                    VStack {
                        Text(remainingBudget.formatAsYen())
                            .font(.title2.bold())
                            .foregroundColor(remainingBudget < 0 ? .red : .green)

                        Text("残り")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .cardStyle()
        }
    }

    // メモセクション
    private func memoSection(memo: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("メモ")
                .font(.headline)
                .padding(.horizontal)

            Text(memo)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
                .padding(.horizontal)
        }
        .padding(.vertical)
    }

}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Plan.self, configurations: config)

    // サンプルデータ作成
    let plan = Plan(
        title: "群馬旅行",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
        themeName: "Sea",
        budget: 50000,
        createdAt: Date()
    )

    NavigationStack {
        PlanDetailCoverView(plan: plan)
            .navigationTitle("群馬旅行")
    }
    .modelContainer(container)
}
