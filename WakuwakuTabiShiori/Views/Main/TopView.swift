//  トップページ（予定一覧画面）
//  ContentView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

struct TopView: View {
    @Environment(\.modelContext) private var modelContext // SwiftData操作用
    @State private var viewModel: TopViewModel // ViewModelを状態として持つ
    @State private var showingNewPlanSheet = false // 新規作成シート表示フラグ

    init() {
        // _viewModelの初期化はinitで行うことが多い (modelContextを渡すため)
        // @Stateの初期化は少し特殊な書き方になる
        self._viewModel = State(initialValue: TopViewModel(modelContext: nil))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // フィルター選択ボタン
                Picker("フィルター", selection: $viewModel.currentFilter) {
                    Text("これからの予定")
                        .tag(TopViewModel.PlanFilter.upcoming)
                    Text("過去の予定")
                        .tag(TopViewModel.PlanFilter.past)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .onChange(of: viewModel.currentFilter) { _, newFilter in
                    viewModel.setFilter(newFilter)
                }

                // エラーメッセージがあれば表示
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }

                if viewModel.isLoading {
                    // ローディング表示
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Spacer()
                } else if viewModel.plans.isEmpty {
                    // 予定がない場合のメッセージ
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "map")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)

                        Text(viewModel.currentFilter == .upcoming ? "これからの予定はありません" : "過去の予定はありません")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Button {
                            showingNewPlanSheet = true
                        } label: {
                            Text("新しい旅行プランを作成")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    Spacer()
                } else {
                    // 予定一覧表示
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
                            ForEach(viewModel.plans) { plan in
                                PlanCardView(plan: plan)
                                    .background(
                                        NavigationLink(value: plan) { EmptyView() }
                                            .opacity(0)
                                    )
                                    .contentShape(Rectangle())
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            viewModel.deletePlan(plan: plan)
                                        } label: {
                                            Label("削除", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("わくわく旅しおり")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewPlanSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.blue)
                            .font(.title2)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationDestination(for: Plan.self) { plan in
                PlanDetailContainerView(plan: plan)
            }
            .sheet(isPresented: $showingNewPlanSheet) {
                // シートが閉じられた時の処理
                viewModel.refreshAfterCreate()
            } content: {
                NavigationStack {
                    NewPlanView()
                }
            }
            .onAppear {
                // Viewが表示された時にViewModelのmodelContextを更新し、データを読み込む
//                viewModel.modelContext = modelContext
                viewModel.fetchPlans()
            }
        }
    }
}

#Preview {
    TopView()
        .modelContainer(for: Plan.self, inMemory: true)
}
