//
//  MainView.swift
//  Sortis
//
//  主界面
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            SidebarView(viewModel: viewModel)
            DetailView(viewModel: viewModel)
        }
    }
}

// 侧边栏
struct SidebarView: View {
    @ObservedObject var viewModel: MainViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            // Logo
            VStack {
                Text("Sortis")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)

            Divider()

            // 主菜单
            Section {
                ForEach(mainMenuItems) { item in
                    MenuItemRow(item: item, isSelected: viewModel.currentRoute == item.rawValue) {
                        viewModel.navigateTo(item.rawValue)
                    }
                }
            }

            // 后台管理
            Section(header: Text("后台管理")) {
                ForEach(adminMenuItems) { item in
                    MenuItemRow(item: item, isSelected: viewModel.currentRoute == item.rawValue) {
                        viewModel.navigateTo(item.rawValue)
                    }
                }
            }

            Divider()

            // 退出登录
            Button(action: {
                appState.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("退出登录")
                }
                .foregroundColor(.red)
            }
        }
        .listStyle(SidebarListStyle())
        .frame(width: AppTheme.drawerWidth)
    }
}

// 菜单项行
struct MenuItemRow: View {
    let item: MenuItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: item.icon)
                    .frame(width: 24)
                Text(item.title)
                Spacer()
            }
            .foregroundColor(isSelected ? .sortisPrimary : .primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .listRowBackground(isSelected ? Color.sortisPrimary.opacity(0.1) : Color.clear)
    }
}

// 详情视图
struct DetailView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.currentRoute {
                case "view":
                    ViewScreen()
                case "dashboard":
                    DashboardView()
                case "messages":
                    AllMessagesView()
                case "categories":
                    CategoriesView()
                case "rules":
                    RulesView()
                case "receivers":
                    ReceiversView()
                case "tokens":
                    TokensView()
                case "settings":
                    SettingsView()
                case "help":
                    HelpView()
                default:
                    ViewScreen()
                }
            }
            .navigationTitle(getCurrentTitle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // 移动端菜单按钮
                }
            }
        }
    }

    private func getCurrentTitle() -> String {
        guard let item = MenuItem(rawValue: viewModel.currentRoute) else { return "Sortis" }
        return item.title
    }
}

// 仪表盘视图
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 统计卡片
                HStack(spacing: 12) {
                    StatCard(title: "总信息", value: "\(viewModel.total)", color: .sortisPrimary)
                    StatCard(title: "未读", value: "\(viewModel.unread)", color: .sortisError)
                    StatCard(title: "星标", value: "\(viewModel.starred)", color: .sortisWarning)
                    StatCard(title: "分类", value: "\(viewModel.categoryCount)", color: .sortisSuccess)
                }
                .padding(.horizontal)

                // 消息趋势
                VStack(alignment: .leading) {
                    Text("消息趋势")
                        .font(.headline)
                        .padding(.horizontal)

                    CardView {
                        if viewModel.activity.isEmpty {
                            Text("暂无趋势数据")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            VStack(spacing: 8) {
                                ForEach(viewModel.activity.suffix(7), id: \.date) { item in
                                    HStack {
                                        Text(formatDate(item.date))
                                            .font(.caption)
                                            .frame(width: 60, alignment: .leading)
                                        Text("信息 \(item.messageCount) · 已读 \(item.readCount)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .background(Color.sortisPrimary.opacity(0.05))
                                    .cornerRadius(6)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .padding(.horizontal)

                // 分类统计
                VStack(alignment: .leading) {
                    Text("分类统计")
                        .font(.headline)
                        .padding(.horizontal)

                    CardView {
                        if viewModel.categoryStats.isEmpty {
                            Text("暂无分类统计数据")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            VStack(spacing: 8) {
                                ForEach(viewModel.categoryStats.prefix(8), id: \.id) { item in
                                    HStack {
                                        Text("\(item.fullPath)")
                                            .font(.caption)
                                            .lineLimit(1)
                                        Spacer()
                                        Text("信息 \(item.messageCount) · 未读 \(item.unreadCount)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .background(Color.sortisPrimary.opacity(0.05))
                                    .cornerRadius(6)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.loadStats()
        }
        .onAppear {
            Task {
                await viewModel.loadStats()
            }
        }
    }

    private func formatDate(_ dateStr: String) -> String {
        let parts = dateStr.split(separator: "-")
        if parts.count >= 3 {
            return "\(parts[1])-\(parts[2])"
        }
        return dateStr.suffix(5).description
    }
}

class DashboardViewModel: ObservableObject {
    @Published var total: Int = 0
    @Published var unread: Int = 0
    @Published var starred: Int = 0
    @Published var categoryCount: Int = 0
    @Published var activity: [ActivityDailyStat] = []
    @Published var categoryStats: [CategoryStatsItem] = []

    private let statsService = StatsService()
    private let categoryService = CategoryService()

    @MainActor
    func loadStats() async {
        do {
            let overview = try await statsService.getStatsOverview(days: 7)
            total = overview.messageStats.total
            unread = overview.messageStats.unread
            starred = overview.messageStats.starred

            let categories = try await categoryService.getCategoryTree(timeRange: "7d")
            categoryCount = categories.count

            let activityResponse = try await statsService.getStatsActivity(days: 30)
            activity = activityResponse.daily

            categoryStats = try await statsService.getStatsCategories()
                .sorted { $0.messageCount > $1.messageCount }
        } catch {
            print("Failed to load dashboard stats: \(error)")
        }
    }
}

// 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// 卡片视图
struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}