//  新規予定の情報を入力する画面
//  NewPlanView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData
import PhotosUI
import CloudKit

struct NewPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // フォーム入力用の状態変数
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(24*60*60) // デフォルトで1日後
    @State private var budget: Double?
    @State private var themeName = "Default"
    @State private var themeColor = Color.orange

    // テーマ選択画面の表示状態
    @State private var showingThemeSelection = false

    // 検証用
    @State private var errorMessage: String?
    @State private var showingAlert = false

    // 保存処理中かどうか
    @State private var isSaving = false

    // ビタミンカラーの配列
    let accentColors: [Color] = [.orange, .yellow, .pink, .blue, .green, .purple]

    var body: some View {
        Form {
            Section {
                TextField("旅行のタイトル", text: $title)
                    .font(.headline)

                DatePicker("出発日", selection: $startDate, displayedComponents: .date)
                DatePicker("帰宅日", selection: $endDate, in: startDate..., displayedComponents: .date)

                HStack {
                    Text("テーマ")
                    Spacer()
                    Text(themeName)
                        .foregroundColor(.secondary)

                    Circle()
                        .fill(themeColor)
                        .frame(width: 20, height: 20)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showingThemeSelection = true
                }
            } header: {
                Text("基本情報")
                    .font(.headline)
                    .foregroundColor(accentColors.randomElement() ?? .orange)
            }

            Section {
                HStack {
                    Text("¥")
                    TextField("予算（任意）", value: $budget, format: .number)
                        .keyboardType(.numberPad)
                }
            } header: {
                Text("予算")
                    .font(.headline)
                    .foregroundColor(accentColors.randomElement() ?? .pink)
            } footer: {
                Text("予算は後からでも変更できます")
                    .font(.caption)
            }

            Section {
                Button {
                    savePlan()
                } label: {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("作成する")
                                .bold()
                        }
                        Spacer()
                    }
                }
                .disabled(title.isEmpty || isSaving)
                .listRowBackground(title.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundColor(.white)
                .padding(.vertical, 5)
            }
            .listRowInsets(EdgeInsets())
        }
        .navigationTitle("新しい旅行プラン")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingThemeSelection) {
            NavigationStack {
                ThemeSelectionView(selectedThemeName: $themeName, selectedColor: $themeColor)
            }
            .presentationDetents([.medium, .large])
        }
        .alert("入力エラー", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "不明なエラーが発生しました")
        }
        .onChange(of: startDate) { oldValue, newValue in
            // 開始日が変更されたとき、終了日が開始日より前なら開始日に設定
            if endDate < newValue {
                endDate = newValue
            }
        }
    }

    // 新規プラン保存処理
    private func savePlan() {
        guard !title.isEmpty else {
            errorMessage = "タイトルを入力してください"
            showingAlert = true
            return
        }

        isSaving = true

        // 保存処理
        let newPlan = Plan(
            id: UUID(),
            title: title,
            startDate: startDate,
            endDate: endDate,
            themeName: themeName,
            budget: budget,
            createdAt: Date(),
            updatedAt: Date()
        )

        // テーマカラーを設定
        newPlan.themeColor = themeColor

        // 各日程を作成
        let calendar = Calendar.current
        if let dayCount = calendar.dateComponents([.day], from: startDate, to: endDate).day {
            for i in 0...dayCount {
                if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                    let dayNumber = i + 1
                    let schedule = Schedule(
                        date: date,
                        title: "\(dayNumber)日目",
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                    // リレーションを設定
                    newPlan.schedules?.append(schedule)
                    schedule.plan = newPlan
                }
            }
        }

        // 現在のユーザーをメンバーに追加（将来的にはCloudKitから取得するユーザー情報を使用）
        newPlan.memberIds = [UUID().uuidString] // 仮のユーザーID

        // データ保存
        modelContext.insert(newPlan)

        // 画面を閉じる
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSaving = false
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        NewPlanView()
            .modelContainer(for: Plan.self, inMemory: true)
    }
}
