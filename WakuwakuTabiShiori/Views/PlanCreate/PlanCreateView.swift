//  旅行プラン作成画面
//  PlanCreateView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData
import UIKit

struct PlanCreateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // 編集中のプラン（新規作成時はnil）
    var plan: Plan?

    // ViewModel
    @StateObject private var viewModel: PlanCreateViewModel

    init(plan: Plan? = nil) {
        self.plan = plan
        self._viewModel = StateObject(wrappedValue: PlanCreateViewModel(
            modelContext: ModelContext(try! ModelContainer(for: Plan.self)),
            plan: plan,
            dismiss: { }
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                // 基本情報セクション
                Section {
                    TextField("旅行タイトル（必須）", text: $viewModel.title)
                        .font(.headline)

                    // 日程選択
                    DatePicker("開始日", selection: $viewModel.startDate, displayedComponents: .date)
                    DatePicker("終了日", selection: $viewModel.endDate, displayedComponents: .date)
                        .onChange(of: viewModel.startDate) { oldValue, newValue in
                            if viewModel.endDate < newValue {
                                viewModel.endDate = newValue
                            }
                        }
                } header: {
                    Text("基本情報")
                        .foregroundColor(viewModel.themeColor)
                }

                // テーマセクション
                Section {
                    // テーマ選択
                    HStack {
                        Text("テーマ")
                        Spacer()
                        Menu {
                            ForEach(Color.themePresets, id: \.name) { name, icon, color in
                                Button {
                                    viewModel.themeName = name
                                    viewModel.themeColor = color
                                } label: {
                                    Label(name, systemImage: icon)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: Color.iconNameForTheme(viewModel.themeName))
                                    .foregroundColor(viewModel.themeColor)
                                Text(viewModel.themeName)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    // カラーピッカー
                    ColorPicker("テーマカラー", selection: $viewModel.themeColor)

                    // 予算設定
                    HStack {
                        Text("¥")
                        TextField("予算（任意）", value: $viewModel.budget, format: .number)
                            .keyboardType(.numberPad)
                    }
                } header: {
                    Text("テーマと予算")
                        .foregroundColor(viewModel.themeColor)
                }

                // メモセクション
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("メモ（任意）")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextEditor(text: $viewModel.memo)
                            .frame(minHeight: 100)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                } header: {
                    Text("メモ")
                        .foregroundColor(viewModel.themeColor)
                }

                // 保存ボタン
                Section {
                    Button {
                        // ViewModelのdismissActionを再設定してから保存処理を呼び出し
                        viewModel.dismissAction = dismiss
                        viewModel.savePlan()
                    } label: {
                        Text(plan == nil ? "旅行プランを作成" : "更新")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(viewModel.isFormValid ? viewModel.themeColor : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .disabled(!viewModel.isFormValid)
                }
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle(plan == nil ? "新規旅行プラン" : "プランを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // ModelContextを最新のものに更新
                viewModel.modelContext = modelContext
                // Dismissアクションの更新
                viewModel.dismissAction = dismiss
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Plan.self, configurations: config)

    return PlanCreateView()
        .modelContainer(container)
}
