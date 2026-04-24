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
                Image("SortisLogo", bundle: AppAssets.bundle)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .padding(.bottom, 8)
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
            Section(
                header: HStack(spacing: 8) {
                    SortisSidebarIcon(kind: .admin, size: 16, color: .secondary)
                    Text("后台管理")
                }
            ) {
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
        let tint = isSelected ? Color.sortisPrimary : Color.primary

        Button(action: action) {
            HStack {
                SortisSidebarIcon(kind: item.iconKind, size: 20, color: tint)
                    .frame(width: 24)
                Text(item.title)
                Spacer()
            }
            .foregroundColor(tint)
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

                Picker("分类统计时间范围", selection: $viewModel.categoryStatsTimeRange) {
                    Text("7天").tag("7d")
                    Text("30天").tag("30d")
                    Text("全部").tag("all")
                }
                .pickerStyle(.segmented)
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
                        color: .sortisError,
                        filled: true
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
                        if viewModel.isLoading && viewModel.categoryTree.isEmpty {
                            DashboardLoadingCard()
                        } else {
                            DashboardCategoryStatsCard(categories: viewModel.categoryTree)
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("接收器详情")
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.horizontal)

                    CardView {
                        DashboardReceiverStatsCard(
                            receivers: viewModel.paginatedReceiverStats,
                            currentPage: viewModel.receiverPage,
                            totalPages: viewModel.receiverTotalPages,
                            onPrevPage: { viewModel.changeReceiverPage(viewModel.receiverPage - 1) },
                            onNextPage: { viewModel.changeReceiverPage(viewModel.receiverPage + 1) }
                        )
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
        .onChange(of: viewModel.categoryStatsTimeRange) { _ in
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
    @Published var categoryTree: [Category] = []
    @Published var categoryStats: [CategoryStatsItem] = []
    @Published var receiverStats: [ReceiverStat] = []
    @Published var categoryStatsTimeRange: String = "7d"
    @Published var receiverPage: Int = 1
    @Published var receiverPageSize: Int = 5
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
            async let activityTask = statsService.getStatsActivity(days: 30)
            async let categoryTreeTask = categoryService.getCategoryTree(
                timeRange: categoryStatsTimeRange == "all" ? nil : categoryStatsTimeRange
            )

            let overview = try await overviewTask
            total = overview.messageStats.total
            unread = overview.messageStats.unread
            starred = overview.messageStats.starred
            receiverStats = overview.receiverStats
            receiverPage = min(max(receiverPage, 1), receiverTotalPages)

            let categories = try await categoryTreeTask
            categoryCount = categories.count
            categoryTree = categories
            categoryStats = flattenCategoryStats(from: categories)
                .sorted { $0.messageCount > $1.messageCount }

            let activityResponse = try await activityTask
            activity = activityResponse.daily
        } catch {
            print("Failed to load dashboard stats: \(error)")
        }
    }

    var receiverTotalPages: Int {
        max(1, Int(ceil(Double(receiverStats.count) / Double(receiverPageSize))))
    }

    var paginatedReceiverStats: [ReceiverStat] {
        let start = max(0, (receiverPage - 1) * receiverPageSize)
        let end = min(start + receiverPageSize, receiverStats.count)
        guard start < end else { return [] }
        return Array(receiverStats[start..<end])
    }

    func changeReceiverPage(_ page: Int) {
        receiverPage = min(max(page, 1), receiverTotalPages)
    }

    private func flattenCategoryStats(from categories: [Category]) -> [CategoryStatsItem] {
        var result: [CategoryStatsItem] = []

        func walk(_ nodes: [Category], pathPrefix: String = "") {
            for category in nodes {
                let path = pathPrefix.isEmpty ? category.name : "\(pathPrefix)/\(category.name)"
                result.append(
                    CategoryStatsItem(
                        id: category.id,
                        name: category.name,
                        fullPath: path,
                        level: max(category.level, 1),
                        messageCount: category.totalCount,
                        unreadCount: category.unreadCount
                    )
                )
                walk(category.children ?? [], pathPrefix: path)
            }
        }

        walk(categories)
        return result
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

struct DashboardReceiverStatsCard: View {
    let receivers: [ReceiverStat]
    let currentPage: Int
    let totalPages: Int
    let onPrevPage: () -> Void
    let onNextPage: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if receivers.isEmpty {
                Text("暂无接收器统计数据")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            } else {
                ForEach(receivers) { receiver in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(receiver.name)
                            .font(.system(size: 13, weight: .medium))
                        Text("\(receiverTypeLabel(receiver.type)) · \(receiver.messageCount) 条")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text("状态 \(receiver.errorMessage?.isEmpty == false ? "异常" : receiver.status)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.sortisGroupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            if totalPages > 1 {
                HStack {
                    Button("上一页", action: onPrevPage)
                        .disabled(currentPage <= 1)
                    Spacer()
                    Text("\(currentPage) / \(totalPages)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("下一页", action: onNextPage)
                        .disabled(currentPage >= totalPages)
                }
                .padding(.top, 4)
            }
        }
    }
}

private func receiverTypeLabel(_ type: String) -> String {
    switch type {
    case "email": return "邮箱"
    case "telegram": return "Telegram"
    case "http_token": return "Webhook"
    case "rss": return "RSS"
    case "websocket": return "WebSocket"
    default: return type
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
    var filled: Bool = false

    var body: some View {
        let titleColor = filled ? Color.white : Color.secondary
        let valueColor = filled ? Color.white : color
        let backgroundColor = filled ? color : color.opacity(0.1)

        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(titleColor)
                .lineLimit(1)
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(backgroundColor)
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
                        color: .sortisError,
                        filled: true
                    )
                }
                .padding(16)
            }
        }
    }
}

struct DashboardCategoryStatsCard: View {
    let categories: [Category]
    @State private var branchPath: [Category] = []

    private var visibleCategories: [Category] {
        branchPath.last?.children ?? categories
    }

    private var currentPathLabel: String {
        branchPath.map(\.name).joined(separator: " / ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !branchPath.isEmpty {
                Button(action: {
                    branchPath.removeLast()
                }) {
                    Text("返回上一级")
                        .font(.system(size: 13, weight: .medium))
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                if !currentPathLabel.isEmpty {
                    Text(currentPathLabel)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                }
            }

            if visibleCategories.isEmpty {
                Text("暂无分类统计数据")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            } else {
                ForEach(Array(visibleCategories.enumerated()), id: \.element.id) { index, category in
                    let hasChildren = !(category.children ?? []).isEmpty

                    Button(action: {
                        if hasChildren {
                            branchPath.append(category)
                        }
                    }) {
                        HStack(alignment: .top, spacing: 8) {
                            HStack(spacing: 6) {
                                Text(category.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                if hasChildren {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(alignment: .center, spacing: 6) {
                                DashboardCountChip(text: "总信息 \(category.totalCount)", background: Color(hex: "69B1FF"))
                                DashboardCountChip(text: "未读 \(category.unreadCount)", background: Color(hex: "FF4D4F"))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.top, index == 0 && branchPath.isEmpty ? 16 : 0)
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 16)
            }
        }
    }
}

struct DashboardCountChip: View {
    let text: String
    let background: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background)
            .clipShape(Capsule())
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
