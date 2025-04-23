//  場所・予定の追加・編集画面
//  PlanItemEditView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PlanItemEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // 編集中のアイテム（新規作成時はnil）
    var item: PlanItem?
    // 所属する日程
    let schedule: Schedule
    // 親の旅行プラン
    let plan: Plan?

    // ViewModel
    @StateObject private var viewModel: PlanItemEditViewModel

    init(item: PlanItem? = nil, schedule: Schedule, plan: Plan?) {
        self.item = item
        self.schedule = schedule
        self.plan = plan
        // ViewModelの初期化（modelContextはonAppearで環境から取得したものに置き換える）
        // 一時的なModelContextを使用し、初期化エラーを避ける
        let temporaryContainer = try! ModelContainer(for: PlanItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        self._viewModel = StateObject(wrappedValue: PlanItemEditViewModel(
            modelContext: ModelContext(temporaryContainer),
            item: item,
            schedule: schedule,
            plan: plan
        ))
    }

    var body: some View {
        Form {
            // 基本情報セクション
            Section {
                TextField("名称（必須）", text: $viewModel.name)
                    .font(.headline)

                DatePicker("時間", selection: $viewModel.time, displayedComponents: [.hourAndMinute, .date])

                // カテゴリー選択
                HStack {
                    Text("カテゴリー")
                    Spacer()
                    Menu {
                        ForEach(Color.categoryDefinitions, id: \.code) { code, name, icon in
                            Button {
                                viewModel.category = code
                            } label: {
                                Label(name, systemImage: icon)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: Color.iconForCategory(viewModel.category))
                                .foregroundColor(viewModel.categoryColor)
                            Text(Color.nameForCategory(viewModel.category))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            } header: {
                Text("基本情報")
                    .foregroundColor(plan?.themeColor ?? .blue)
            }

            // メモと住所
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("メモ（任意）")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextEditor(text: $viewModel.memo)
                        .frame(minHeight: 100)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

                HStack {
                    Image(systemName: "mappin")
                        .foregroundColor(.red)
                    TextField("住所", text: $viewModel.address)
                }
            }

            // 写真セクション
            Section {
                VStack(alignment: .leading) {
                    if let uiImage = viewModel.uiImage {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                            Spacer()
                        }

                        // 写真削除ボタン
                        Button(role: .destructive) {
                            viewModel.uiImage = nil
                            viewModel.photoData = nil
                        } label: {
                            Label("写真を削除", systemImage: "trash")
                        }
                        .padding(.top, 8)
                    }

                    // 写真選択ボタン
                    PhotosPicker(selection: $viewModel.photoItem, matching: .images) {
                        Label("写真を追加", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.categoryColor)
                    .onChange(of: viewModel.photoItem) { oldValue, newValue in
                        if let newItem = newValue {
                            Task {
                                await viewModel.loadImage(from: newItem)
                            }
                        }
                    }
                }
            } header: {
                Text("写真")
                    .foregroundColor(plan?.themeColor ?? .blue)
            }

            // 予算セクション
            Section {
                HStack {
                    Text("¥")
                    TextField("費用（任意）", value: $viewModel.cost, format: .number)
                        .keyboardType(.numberPad)
                }

                Toggle("完了済み", isOn: $viewModel.isCompleted)
            } header: {
                Text("費用・状態")
                    .foregroundColor(plan?.themeColor ?? .blue)
            }

            // 保存ボタン
            Section {
                Button {
                    // 保存処理を呼び出し
                    viewModel.saveItem()
                } label: {
                    Text("保存")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(viewModel.isFormValid ? (plan?.themeColor ?? .blue) : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .disabled(!viewModel.isFormValid)
            }
            .listRowInsets(EdgeInsets())
        }
        .navigationTitle(item == nil ? "新規予定" : "予定を編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") {
                    dismiss()
                }
            }
        }
        .onAppear {
            // ModelContextを更新
            viewModel.modelContext = modelContext
            // dismissActionを設定
            viewModel.dismissAction = dismiss
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Plan.self, configurations: config)

    // サンプルデータ
    let plan = Plan(title: "群馬旅行", themeName: "Default", createdAt: Date())
    let schedule = Schedule(date: Date(), title: "1日目")

    return NavigationStack {
        PlanItemEditView(schedule: schedule, plan: plan)
    }
    .modelContainer(container)
}
