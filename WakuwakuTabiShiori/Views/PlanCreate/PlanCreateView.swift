////  旅行プラン作成画面
////  PlanCreateView.swift
////  WakuwakuTabiShiori
////
////  Created by 二渡和輝 on 2025/04/19.
////
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
    private let timeZoneOptions: [String] = [
        "Asia/Tokyo",
        "Asia/Seoul",
        "Asia/Taipei",
        "Asia/Shanghai",
        "Asia/Bangkok",
        "Europe/London",
        "Europe/Paris",
        "America/Los_Angeles",
        "America/New_York",
        "Australia/Sydney"
    ]

    init(plan: Plan? = nil) {
        self.plan = plan
        // ViewModelの初期化（modelContextはonAppearで環境から取得したものに置き換える）
        // 一時的なModelContextを使用し、初期化エラーを避ける
        let temporaryContainer = try! ModelContainer(for: Plan.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        self._viewModel = StateObject(wrappedValue: PlanCreateViewModel(
            modelContext: ModelContext(temporaryContainer),
            existingPlan: plan // 既存のプランを渡す
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack {
                    Form {
                        Section {
                            TextField("旅行タイトル（必須）", text: $viewModel.title)
                                .font(.headline)

                            DatePicker("開始日", selection: $viewModel.startDate, displayedComponents: .date)
                            DatePicker("終了日", selection: $viewModel.endDate, in: viewModel.startDate..., displayedComponents: .date)
                            timeZonePicker
                        } header: {
                            sectionHeader("基本情報")
                        }

                        Section {
                            themePickerSection
                            ColorPicker("テーマカラー", selection: $viewModel.themeColor)
                            budgetInput
                        } header: {
                            sectionHeader("テーマと予算")
                        }

                        Section {
                            memoInput
                        } header: {
                            sectionHeader("メモ")
                        }
                    }
                    .scrollContentBackground(.hidden) // Formの背景を透明に
                    .background(Color.clear)

                    // バリデーションエラー表示
                    if let error = viewModel.validationError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                    }

                    // ボタンは常に下に固定
                    Button(action: {
                        if viewModel.addPlan() {
                            dismiss()
                        }
                    }) {
                        Text(plan == nil ? "旅行プランを作成" : "更新")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding([.horizontal, .bottom])
                }
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
                // 環境から取得したModelContextに置き換える
                viewModel.updateModelContext(modelContext)
            }
        }
    }


    @ViewBuilder
    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(viewModel.themeColor)
            .textCase(nil)
    }

    var themePickerSection: some View {
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
    }

    var budgetInput: some View {
        HStack {
            Text("¥")
            TextField("予算（任意）", value: $viewModel.budget, format: .number)
                .keyboardType(.numberPad)
        }
    }

    var memoInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("メモ（任意）")
                .font(.caption)
                .foregroundColor(.secondary)
            TextEditor(text: $viewModel.memo)
                .frame(minHeight: 100)
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }

    private var timeZonePicker: some View {
        HStack {
            Text("時間帯")
            Spacer()
            Menu {
                ForEach(timeZoneOptions, id: \.self) { identifier in
                    Button {
                        viewModel.timeZoneIdentifier = identifier
                    } label: {
                        Text(displayName(for: identifier))
                    }
                }
            } label: {
                HStack {
                    Text(displayName(for: viewModel.timeZoneIdentifier))
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func displayName(for identifier: String) -> String {
        if let timeZone = TimeZone(identifier: identifier) {
            return timeZone.identifier
        }
        return identifier
    }
}
