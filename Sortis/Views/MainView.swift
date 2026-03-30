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
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("最近 7 天概览")
                        .font(.system(size: 22, weight: .bold))
                    Text("布局对齐 web 仪表盘，统计与趋势分区显示")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                HStack(spacing: 12) {
                    StatCard(title: "总信息", value: "\(viewModel.total)", color: .sortisInfo)
                    StatCard(title: "未读", value: "\(viewModel.unread)", color: .sortisError)
                }
                .padding(.horizontal)

                HStack(spacing: 12) {
                    StatCard(title: "星标", value: "\(viewModel.starred)", color: .sortisWarning)
                    StatCard(title: "分类", value: "\(viewModel.categoryCount)", color: .sortisSuccess)
                }
                .padding(.horizontal)

                HStack(spacing: 8) {
                    DashboardSummaryChip(
                        title: "30天总信息",
                        value: "\(viewModel.totalMessages30d)",
                        color: .sortisPrimary
                    )
                    DashboardSummaryChip(
                        title: "30天已读",
                        value: "\(viewModel.totalRead30d)",
                        color: .sortisSuccess
                    )
                    DashboardSummaryChip(
                        title: "30天未读",
                        value: "\(viewModel.totalUnread30d)",
                        color: .sortisError
                    )
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("信息趋势")
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.horizontal)

                    CardView {
                        if viewModel.isLoading && viewModel.activity.isEmpty {
                            DashboardLoadingCard()
                        } else {
                            DashboardTrendCard(activity: viewModel.activity)
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("分类统计")
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.horizontal)

                    CardView {
                        if viewModel.isLoading && viewModel.categoryStats.isEmpty {
                            DashboardLoadingCard()
                        } else {
                            DashboardCategoryStatsCard(categories: viewModel.categoryStats)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear {
            Task {
                await viewModel.loadStats()
            }
        }
    }
}

class DashboardViewModel: ObservableObject {
    @Published var total: Int = 0
    @Published var unread: Int = 0
    @Published var starred: Int = 0
    @Published var categoryCount: Int = 0
    @Published var activity: [ActivityDailyStat] = []
    @Published var categoryStats: [CategoryStatsItem] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false

    private let statsService = StatsService()
    private let categoryService = CategoryService()

    @MainActor
    func loadStats() async {
        isLoading = true
        await fetchDashboardData()
        isLoading = false
    }

    @MainActor
    func refresh() async {
        isRefreshing = true
        await fetchDashboardData()
        isRefreshing = false
    }

    @MainActor
    private func fetchDashboardData() async {
        do {
            async let overviewTask = statsService.getStatsOverview(days: 7)
            async let categoryTreeTask = categoryService.getCategoryTree(timeRange: "7d")
            async let activityTask = statsService.getStatsActivity(days: 30)
            async let categoryStatsTask = statsService.getStatsCategories()

            let overview = try await overviewTask
            total = overview.messageStats.total
            unread = overview.messageStats.unread
            starred = overview.messageStats.starred

            let categories = try await categoryTreeTask
            categoryCount = categories.count

            let activityResponse = try await activityTask
            activity = activityResponse.daily

            categoryStats = try await categoryStatsTask
                .sorted { $0.messageCount > $1.messageCount }
        } catch {
            print("Failed to load dashboard stats: \(error)")
        }
    }

    var totalMessages30d: Int {
        activity.reduce(0) { $0 + $1.messageCount }
    }

    var totalRead30d: Int {
        activity.reduce(0) { $0 + $1.readCount }
    }

    var totalUnread30d: Int {
        activity.reduce(0) { $0 + max(0, $1.messageCount - $1.readCount) }
    }
}

// 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
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

struct DashboardSummaryChip: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct DashboardLoadingCard: View {
    var body: some View {
        VStack {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 180)
        }
        .padding(.horizontal, 16)
    }
}

struct DashboardTrendCard: View {
    let activity: [ActivityDailyStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if activity.isEmpty {
                Text("暂无趋势数据")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            } else {
                ForEach(Array(activity.suffix(7).enumerated()), id: \.element.date) { index, item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatDashboardDate(item.date))
                            .font(.system(size: 12, weight: .medium))
                        Text("信息 \(item.messageCount) · 已读 \(item.readCount) · 未读 \(max(0, item.messageCount - item.readCount))")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, index == 0 ? 16 : 0)
                }

                HStack(spacing: 12) {
                    DashboardSummaryChip(
                        title: "30天总信息",
                        value: "\(activity.reduce(0) { $0 + $1.messageCount })",
                        color: .sortisPrimary
                    )
                    DashboardSummaryChip(
                        title: "30天已读",
                        value: "\(activity.reduce(0) { $0 + $1.readCount })",
                        color: .sortisSuccess
                    )
                    DashboardSummaryChip(
                        title: "30天未读",
                        value: "\(activity.reduce(0) { $0 + max(0, $1.messageCount - $1.readCount) })",
                        color: .sortisError
                    )
                }
                .padding(16)
            }
        }
    }
}

struct DashboardCategoryStatsCard: View {
    let categories: [CategoryStatsItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if categories.isEmpty {
                Text("暂无分类统计数据")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            } else {
                ForEach(Array(categories.prefix(8).enumerated()), id: \.element.id) { index, category in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(width: 24, alignment: .leading)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.fullPath.isEmpty ? category.name : category.fullPath)
                                .font(.system(size: 13, weight: .medium))
                                .lineLimit(1)
                            Text("信息 \(category.messageCount) · 未读 \(category.unreadCount)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, index == 0 ? 16 : 0)
                }
                Spacer(minLength: 16)
            }
        }
    }
}

private func formatDashboardDate(_ dateStr: String) -> String {
    let parts = dateStr.split(separator: "-")
    if parts.count >= 3 {
        return "\(parts[1])-\(parts[2])"
    }
    return String(dateStr.suffix(5))
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
