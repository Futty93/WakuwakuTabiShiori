//  日程内の各「場所・予定」行のビュー
//  PlanItemRowView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

struct PlanItemRowView: View {
   @Environment(\.modelContext) private var modelContext
   @Bindable var item: PlanItem
   @State private var showingEditSheet = false
   @State private var showingDeleteAlert = false

   // ViewModel
   @StateObject private var viewModel: PlanItemViewModel

   init(item: PlanItem) {
       self.item = item
       // ViewModelの初期化（modelContextはonAppearで環境から取得したものに置き換える）
       // 一時的なModelContextを使用し、初期化エラーを避ける
       let temporaryContext = createTemporaryModelContext(PlanItem.self)
       self._viewModel = StateObject(wrappedValue: PlanItemViewModel(
           item: item,
           modelContext: temporaryContext
       ))
   }

   // カテゴリーに基づく色の取得
   private var categoryColor: Color {
       // Color+Themesの拡張メソッドを使用
       Color.fromCategory(item.category)
   }

   var body: some View {
       VStack(spacing: 0) {
           // 時間表示
           HStack {
               Text(item.time.formatHourMinute())
                   .font(.caption)
                   .padding(.horizontal, 8)
                   .padding(.vertical, 2)
                   .background(
                       Capsule()
                           .fill(categoryColor.opacity(0.15))
                   )
                   .foregroundColor(categoryColor)

               Spacer()

               // 金額（あれば）
               if let cost = item.cost {
                   Text(cost.formatAsYen())
                       .font(.caption)
                       .foregroundColor(.secondary)
               }
           }
           .padding(.bottom, 4)

           // メインコンテンツ
           HStack(alignment: .top, spacing: 12) {
               // カテゴリーアイコン
               Image(systemName: item.categoryIcon)
                   .font(.system(size: 18))
                   .foregroundColor(.white)
                   .frame(width: 30, height: 30)
                   .background(categoryColor)
                   .clipShape(Circle())

               VStack(alignment: .leading, spacing: 6) {
                   // タイトル
                   Text(item.name)
                       .font(.headline)
                       .lineLimit(2)

                   // メモ（あれば）
                   if let memo = item.memo, !memo.isEmpty {
                       Text(memo)
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                           .lineLimit(3)
                   }

                   // 住所（あれば）
                   if let address = item.address, !address.isEmpty {
                       HStack(alignment: .top, spacing: 4) {
                           Image(systemName: "mappin")
                               .font(.caption)
                               .foregroundColor(.red)
                           Text(address)
                               .font(.caption)
                               .foregroundColor(.gray)
                               .lineLimit(2)
                       }
                   }
               }

               Spacer()

               // 写真（あれば）
               if let photo = item.photo {
                   Image(uiImage: photo)
                       .resizable()
                       .scaledToFill()
                       .frame(width: 60, height: 60)
                       .clipShape(RoundedRectangle(cornerRadius: 8))
               }
           }
       }
       .padding(.horizontal, 8)
       .padding(.vertical, 12)
       .contentShape(Rectangle())
       .background(Color(.systemBackground))
       .cornerRadius(12)
       .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
       // タップでアイテム編集
       .onTapGesture {
           showingEditSheet = true
       }
       // スワイプで削除
       .swipeActions(edge: .trailing) {
           Button(role: .destructive) {
               showingDeleteAlert = true
           } label: {
               Label("削除", systemImage: "trash")
           }
       }
       // 長押しでコンテキストメニュー
       .contextMenu {
           Button(role: .destructive) {
               showingDeleteAlert = true
           } label: {
               Label("削除", systemImage: "trash")
           }
       }
       .sheet(isPresented: $showingEditSheet) {
           NavigationStack {
               PlanItemEditView(item: item, schedule: item.schedule, plan: item.schedule.plan)
           }
       }
       .alert("予定を削除", isPresented: $showingDeleteAlert) {
           Button("キャンセル", role: .cancel) { }
           Button("削除", role: .destructive) {
               viewModel.deleteItem()
           }
       } message: {
           Text("\(item.name) を削除してもよろしいですか？この操作は取り消せません。")
       }
       .onAppear {
           // ModelContextを更新（@Environmentから取得）
           viewModel.modelContext = modelContext
           // アイテムへの参照も最新に更新
           // NOTE: 最新のitemへの参照に差し替える（SwiftDataの問題対応）
           viewModel.item = item
       }
   }
}

#Preview {
   let config = ModelConfiguration(isStoredInMemoryOnly: true)
   let container = try! ModelContainer(for: Plan.self, configurations: config)

   let plan = Plan(title: "群馬旅行", createdAt: Date())
   let schedule = Schedule(date: Date(), title: "1日目", plan: plan)
   plan.schedules.append(schedule)
   let item = PlanItem(
       time: Date(),
       category: "meal",
       name: "群馬名物 水沢うどん",
       memo: "有名なうどん店。予約しておくとスムーズ。",
       cost: 1500,
       schedule: schedule
   )

   return PlanItemRowView(item: item)
       .padding()
       .modelContainer(container)
}
