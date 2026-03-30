//
//  ViewScreen.swift
//  Sortis
//
//  信息视图
//

import SwiftUI

struct ViewScreen: View {
    @StateObject private var viewModel = ViewViewModel()

    var body: some View {
        Group {
            if viewModel.selectedCategory != nil {
                CategoryMessagesView(viewModel: viewModel)
            } else {
                CategoryNavigationView(viewModel: viewModel)
            }
        }
    }
}

// 分类导航视图
struct CategoryNavigationView: View {
    @ObservedObject var viewModel: ViewViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // 统计卡片
                HStack(spacing: 12) {
                    StatItem(
                        label: "总信息",
                        value: viewModel.stats?.total ?? viewModel.total,
                        color: .sortisPrimary
                    )
                    StatItem(
                        label: "未读",
                        value: viewModel.stats?.unread ?? 0,
                        color: .sortisError
                    )
                    StatItem(
                        label: "星标",
                        value: viewModel.stats?.starred ?? 0,
                        color: .sortisWarning
                    )
                    StatItem(
                        label: "分类",
                        value: flattenCategories(viewModel.categories).count,
                        color: .sortisSuccess
                    )
                }
                .padding(.horizontal)
                .padding(.top)

                // 时间范围筛选
                HStack {
                    Spacer()
                    TimeRangePicker(timeRange: $viewModel.timeRange) {
                        viewModel.setTimeRange($0)
                    }
                }
                .padding(.horizontal)

                // 分类列表
                LazyVStack(spacing: 6) {
                    CategoryTreeItem(
                        name: "全部信息",
                        icon: "📋",
                        iconUrl: nil,
                        level: 0,
                        isSelected: viewModel.selectedCategory == nil,
                        totalCount: viewModel.total,
                        readCount: viewModel.total - (viewModel.stats?.unread ?? 0),
                        unreadCount: viewModel.stats?.unread ?? 0
                    ) {
                        viewModel.selectCategory(categoryId: nil, categoryName: "全部信息")
                    }

                    ForEach(viewModel.categories, id: \.id) { category in
                        CategoryTreeItem(
                            name: category.name,
                            icon: category.icon,
                            iconUrl: category.iconUrl,
                            level: (category.level - 1).clamped(to: 0...100),
                            isSelected: viewModel.selectedCategory == category.id,
                            totalCount: category.totalCount,
                            readCount: category.readCount,
                            unreadCount: category.unreadCount
                        ) {
                            viewModel.selectCategory(categoryId: category.id, categoryName: category.name)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .refreshable {
            viewModel.refresh()
        }
    }
}

// 分类消息视图
struct CategoryMessagesView: View {
    @ObservedObject var viewModel: ViewViewModel

    var body: some View {
        VStack {
            // 顶部导航栏
            HStack {
                Button(action: { viewModel.clearSelectedCategory() }) {
                    Image(systemName: "arrow.left")
                }
                Text(viewModel.selectedCategoryName ?? "分类")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // 分页和时间过滤
            HStack {
                PaginationControl(
                    currentPage: viewModel.currentPage,
                    totalPages: viewModel.totalPages,
                    onPageChange: { viewModel.changePage($0) }
                )

                Spacer()

                TimeRangePicker(timeRange: $viewModel.timeRange) {
                    viewModel.setTimeRange($0)
                }
            }
            .padding(.horizontal)

            // 消息列表
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.messages.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("暂无信息")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            MessageCard(message: message) {
                                viewModel.selectMessage(message)
                            }
                            .onLongPressGesture {
                                viewModel.setActionMessage(message)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .refreshable {
                    viewModel.refresh()
                }
            }
        }
        .sheet(item: $viewModel.selectedMessage) { message in
            MessageDetailSheet(
                message: message,
                onToggleRead: { viewModel.toggleRead(messageId: message.id) },
                onToggleStar: { viewModel.toggleStar(messageId: message.id) }
            ) {
                viewModel.selectMessage(nil)
            }
        }
        .sheet(item: $viewModel.actionMessage) { message in
            MessageActionSheet(
                message: message,
                categories: viewModel.getAllFlatCategories(),
                onToggleRead: { viewModel.toggleRead(messageId: message.id) },
                onToggleStar: { viewModel.toggleStar(messageId: message.id) },
                onMove: { viewModel.moveMessage(messageId: message.id, categoryId: $0) },
                onDelete: { viewModel.deleteMessage(messageId: message.id) },
                onDismiss: { viewModel.setActionMessage(nil) }
            )
        }
    }
}

// 分类树项
struct CategoryTreeItem: View {
    let name: String
    let icon: String?
    let iconUrl: String?
    let level: Int
    let isSelected: Bool
    let totalCount: Int
    let readCount: Int
    let unreadCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                // 缩进
                if level > 0 {
                    ForEach(0..<level, id: \.self) { _ in
                        Spacer().frame(width: 12)
                    }
                }

                CategoryIconView(
                    icon: icon,
                    iconUrl: iconUrl,
                    size: 18,
                    cornerRadius: 4
                )

                // 名称
                Text(name)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .sortisPrimary : .primary)
                    .lineLimit(1)

                Spacer()

                // 统计
                Text("总\(totalCount)")
                    .font(.caption)
                    .foregroundColor(.sortisInfo)
                Text("已\(readCount)")
                    .font(.caption)
                    .foregroundColor(.sortisInfo)
                Text("未\(unreadCount)")
                    .font(.caption)
                    .foregroundColor(.sortisSuccess)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(isSelected ? Color.sortisPrimary.opacity(0.1) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 统计项
struct StatItem: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack {
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// 时间范围选择器
struct TimeRangePicker: View {
    @Binding var timeRange: String
    let onChange: (String) -> Void

    @State private var isExpanded = false

    let options: [(String, String)] = [
        ("all", "全部"),
        ("1d", "1天"),
        ("3d", "3天"),
        ("7d", "7天"),
        ("30d", "30天")
    ]

    var body: some View {
        Menu {
            ForEach(options, id: \.0) { value, label in
                Button(label) {
                    timeRange = value
                    onChange(value)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(options.first { $0.0 == timeRange }?.1 ?? "7天")
                    .font(.caption)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
    }
}

// 分页控件
struct PaginationControl: View {
    let currentPage: Int
    let totalPages: Int
    let onPageChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                if currentPage > 1 { onPageChange(currentPage - 1) }
            }) {
                Image(systemName: "chevron.left")
                    .font(.caption)
            }
            .disabled(currentPage <= 1)

            Text("\(currentPage)/\(max(totalPages, 1))")
                .font(.caption)

            Button(action: {
                if currentPage < totalPages { onPageChange(currentPage + 1) }
            }) {
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .disabled(currentPage >= totalPages)
        }
        .foregroundColor(.secondary)
    }
}

// Comparable 扩展
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
