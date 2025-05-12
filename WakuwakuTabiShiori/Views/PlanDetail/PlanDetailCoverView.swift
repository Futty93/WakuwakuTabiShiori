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
    @State private var showingEditSheet = false

    // ViewModel
    @StateObject private var viewModel: PlanDetailViewModel

    init(plan: Plan) {
        self.plan = plan
        // ViewModelの初期化（modelContextはonAppearで環境から取得したものに置き換える）
        // 一時的なModelContextを使用し、初期化エラーを避ける
        let temporaryContainer = try! ModelContainer(for: Plan.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        self._viewModel = StateObject(wrappedValue: PlanDetailViewModel(
            plan: plan,
            modelContext: ModelContext(temporaryContainer)
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

                // メモセクション
                if let memo = plan.memo, !memo.isEmpty {
                    memoSection(memo: memo)
                }

                // シェアボタン
                shareButton
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

                        Text("\(dateFormatter.string(from: plan.startDate)) 〜 \(dateFormatter.string(from: plan.endDate))")
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
                    // plan.memberIds が nil でないことを確認し、安全にアンラップ
                    if let memberIds = plan.memberIds, !memberIds.isEmpty {
                        // 他のメンバーがいる場合のみ表示 (自分自身を除く)
                        // ※ dropFirst() だと自分自身も表示される可能性があるため、
                        //   より正確には自分のIDを除外するなどの処理が必要だが、
                        //   ここでは仮実装として memberIds が空でないかで判定
                        // ※ 将来的にUserモデルを使う場合はここのロジックが変わる

                        // memberIds 配列からメンバーアイコンを表示
                        ForEach(memberIds, id: \.self) { memberId in
                            // TODO: 実際には memberId を使ってユーザー情報を取得し表示する
                            // 例: if memberId != myUserId { memberIcon(...) }
                            // 今は仮でゲスト表示
                            if memberId != "currentUserIdentifierPlaceholder" { // 仮の自分のIDと比較
                                memberIcon(name: "ゲスト", isCurrentUser: false)
                            }
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
                        Text(currencyFormatter.string(from: NSNumber(value: remainingBudget)) ?? "¥0")
                            .font(.title2.bold())
                            .foregroundColor(remainingBudget < 0 ? .red : .green)

                        Text("残り")
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

    // シェアボタン
    private var shareButton: some View {
        Button {
            showingShareSheet = true
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("共有する")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(plan.themeColor)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.top, 20)
        .sheet(isPresented: $showingShareSheet) {
            // 共有シートの実装（将来的に）
            Text("共有機能は準備中です")
                .presentationDetents([.medium])
        }
    }

    // メンバーアイコン
    private func memberIcon(name: String, isCurrentUser: Bool) -> some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isCurrentUser ? plan.themeColor : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)

                Image(systemName: "person.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isCurrentUser ? .white : .gray)
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
        title: "群馬旅行",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
        themeName: "Sea",
        budget: 50000,
        memberIds: [UUID().uuidString, UUID().uuidString],
        createdAt: Date()
    )

    NavigationStack {
        PlanDetailCoverView(plan: plan)
            .navigationTitle("群馬旅行")
    }
    .modelContainer(container)
}
