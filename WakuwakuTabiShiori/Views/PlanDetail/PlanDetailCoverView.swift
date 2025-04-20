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
    @State private var showingShareSheet = false
    @Environment(\.modelContext) private var modelContext

    // ViewModel
    @StateObject private var viewModel: PlanDetailViewModel

    init(plan: Plan) {
        self.plan = plan
        self._viewModel = StateObject(wrappedValue: PlanDetailViewModel(
            plan: plan,
            modelContext: ModelContext(try! ModelContainer(for: Plan.self))
        ))
    }

    // 日付フォーマッター
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    // 通貨フォーマッター
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.currencySymbol = "¥"
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ヘッダー背景
                themeBanner

                // 情報セクション
                infoSection

                // メンバーセクション
                memberSection

                // 予算セクション
                if let budget = plan.budget {
                    budgetSection(budget: budget)
                }

                // シェアボタン
                shareButton
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // ModelContextを更新
            viewModel.modelContext = modelContext
            // プランへの参照も最新に更新
            viewModel.plan = plan
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
            // 期間
            HStack(alignment: .top) {
                Image(systemName: "calendar")
                    .foregroundColor(plan.themeColor)
                    .frame(width: 26)

                VStack(alignment: .leading) {
                    Text("旅行期間")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(dateFormatter.string(from: plan.startDate)) 〜 \(dateFormatter.string(from: plan.endDate))")
                        .font(.headline)

                    Text("\(plan.totalDays)日間")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }

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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .padding()
    }

    // メンバーセクション
    private var memberSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("メンバー")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // 自分（現在のユーザー）
                    memberIcon(name: "あなた", isCurrentUser: true)

                    // 他のメンバー（仮）
                    if plan.memberIds.count > 1 {
                        ForEach(plan.memberIds.dropFirst(), id: \.self) { _ in
                            // 実際にはUserデータからアバターや名前を取得
                            memberIcon(name: "ゲスト", isCurrentUser: false)
                        }
                    }

                    // メンバー追加ボタン（将来実装）
                    Button {
                        // 招待機能を実装
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)

                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
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
                    Text(currencyFormatter.string(from: NSNumber(value: budget)) ?? "¥0")
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
                        Text(currencyFormatter.string(from: NSNumber(value: usedBudget)) ?? "¥0")
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
                        Text(currencyFormatter.string(from: NSNumber(value: max(0, remainingBudget))) ?? "¥0")
                            .font(.title2.bold())
                            .foregroundColor(remainingBudget < 0 ? .red : .blue)

                        Text("残り予算")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal)
        }
        .padding(.vertical)
    }

    // シェアボタン
    private var shareButton: some View {
        Button {
            showingShareSheet = true
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("この旅行プランをシェア")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(plan.themeColor)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
    }

    // メンバーアイコン
    private func memberIcon(name: String, isCurrentUser: Bool) -> some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isCurrentUser ? plan.themeColor.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundColor(isCurrentUser ? plan.themeColor : .gray)
            }

            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Plan.self, configurations: config)

    // サンプルデータ作成
    let plan = Plan(
        id: UUID(),
        title: "群馬旅行",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
        themeName: "Sea",
        budget: 50000,
        memberIds: [UUID().uuidString, UUID().uuidString],
        createdAt: Date()
    )

    // テーマカラーを設定
    plan.themeColor = .blue

    return NavigationStack {
        PlanDetailCoverView(plan: plan)
            .navigationTitle("群馬旅行")
    }
    .modelContainer(container)
}
