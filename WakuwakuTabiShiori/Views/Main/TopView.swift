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

    init() {
        // _viewModelの初期化はinitで行うことが多い (modelContextを渡すため)
        // @Stateの初期化は少し特殊な書き方になる
        self._viewModel = State(initialValue: TopViewModel(modelContext: nil))
    }

    var body: some View {
        NavigationStack { // または NavigationView
            VStack {
                // フィルター選択ボタン
                Picker("フィルター", selection: $viewModel.currentFilter) {
                    Text("これからの予定").tag(TopViewModel.PlanFilter.upcoming)
                    Text("過去の予定").tag(TopViewModel.PlanFilter.past)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: viewModel.currentFilter) { _, newFilter in
                    viewModel.setFilter(newFilter) // フィルター変更時にViewModelのメソッド呼び出し
                }

                if viewModel.isLoading {
                    ProgressView() // ローディング表示
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.plans) { plan in
                            NavigationLink(value: plan) { // 画面遷移用
                                PlanCardView(plan: plan) // 予定カード (ViewModelから渡されたデータを使う)
                            }
                        }
                        .onDelete { indexSet in
                            // スワイプ削除時の処理
                            deletePlans(at: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("旅行プラン")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        NewPlanView() // 新規作成画面へ
                    } label: {
                        Image(systemName: "plus.circle.fill") // "+" ボタン
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.blue) // ポップな色使い
                            .font(.title2)
                    }
                }
            }
            .navigationDestination(for: Plan.self) { plan in
                PlanDetailContainerView(plan: plan) // 詳細画面へ遷移
            }
            .onAppear {
                // Viewが表示された時にViewModelのmodelContextを更新し、データを読み込む
//                viewModel.modelContext = modelContext
                viewModel.fetchPlans()
            }
        }
    }

    // Listの削除処理
    private func deletePlans(at offsets: IndexSet) {
        offsets.map { viewModel.plans[$0] }.forEach { plan in
            viewModel.deletePlan(plan: plan) // ViewModelの削除メソッド呼び出し
        }
    }
}


#Preview {
    TopView()
        .modelContainer(for: Item.self, inMemory: true)
}
