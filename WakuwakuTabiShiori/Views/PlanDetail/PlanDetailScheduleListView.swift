//  日程リスト表示部分
//  PlanDetailScheduleListView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//
//
import SwiftUI
import SwiftData

struct PlanDetailScheduleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var plan: Plan

    // 選択中の日程インデックス
    @State private var selectedDayIndex = 0
    @State private var showingAddItemSheet = false
    @State private var selectedSchedule: Schedule?

    // 日付フォーマッター
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    // 現在選択中の日程を取得
    private var currentSchedule: Schedule {
        let sortedSchedules = plan.schedules.sorted { $0.date < $1.date }
        guard !sortedSchedules.isEmpty else {
            // 日程が存在しない場合は空のScheduleを返す
            return Schedule(date: Date(), title: "1日目")
        }
        return sortedSchedules[selectedDayIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            // 日付選択タブ
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    if !plan.schedules.isEmpty {
                        let schedules = plan.schedules.sorted { $0.date < $1.date }
                        ForEach(Array(schedules.enumerated()), id: \.element.id) { index, schedule in
                            dayTabButton(day: schedule.date, dayNumber: index + 1, isSelected: index == selectedDayIndex)
                                .onTapGesture {
                                    selectedDayIndex = index
                                    selectedSchedule = schedule
                                }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
            }
            
            // 日程概要（タイトル、メモ）
            dayHeader(schedule: currentSchedule)

            // 日程コンテンツ
            ScrollView {
                VStack(spacing: 0) {
                    // スケジュールタイムライン
                    if let items = currentSchedule.items, !items.isEmpty {
                        ForEach(currentSchedule.sortedItems) { item in
                            PlanItemRowView(item: item)
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                        }
                    } else {
                        // 予定アイテムがない場合
                        emptyScheduleView
                    }

                    // 追加ボタン
                    Button {
                        selectedSchedule = currentSchedule
                        showingAddItemSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("予定を追加")
                        }
                        .font(.headline)
                        .foregroundColor(plan.themeColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(plan.themeColor, lineWidth: 2)
                                .background(Color.white.cornerRadius(12))
                        )
                        .padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingAddItemSheet) {
            NavigationStack {
                // PlanItemの新規追加のために呼び出されており、編集のための呼び出しはPlanItemRowViewで定義
                PlanItemEditView(schedule: currentSchedule, plan: plan)
            }
        }
        .onAppear {
            // 初期表示時にselectedScheduleを設定
            selectedSchedule = currentSchedule
        }
    }

    // 日付タブボタン
    private func dayTabButton(day: Date, dayNumber: Int, isSelected: Bool) -> some View {
        VStack(spacing: 4) {
            // 日数
            Text("\(dayNumber)日目")
                .font(.caption)
                .bold()
                .foregroundColor(isSelected ? .white : .primary)

            // 日付
            Text(dateFormatter.string(from: day))
                .font(.caption2)
                .foregroundColor(isSelected ? .white : .secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? plan.themeColor : Color.gray.opacity(0.1))
        )
    }

    // 日程ヘッダー
    private func dayHeader(schedule: Schedule) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // タイトル編集部分
            HStack {
                Image(systemName: "calendar.day.timeline.left")
                    .foregroundColor(plan.themeColor)

                Text(schedule.title ?? "\(selectedDayIndex + 1)日目")
                    .font(.title2.bold())

                Spacer()
            }

            // メモ部分（あれば）
            if let notes = schedule.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .padding(.bottom, 8)
    }

    // 予定がない場合の表示
    private var emptyScheduleView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("この日の予定はまだありません")
                .font(.headline)
                .foregroundColor(.gray)

            Text("「予定を追加」ボタンから予定を登録しましょう")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
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

    // 日程を作成
    let schedule1 = Schedule(date: plan.startDate, title: "1日目：前橋観光")
    let schedule2 = Schedule(date: plan.endDate, title: "2日目：高崎観光")
    plan.schedules = [schedule1, schedule2]

    return NavigationStack {
        PlanDetailScheduleListView(plan: plan)
    }
    .modelContainer(container)
}
