//
//  AllMessagesView.swift
//  Sortis
//
//  所有消息视图
//

import SwiftUI

struct AllMessagesView: View {
    @StateObject private var viewModel = AllMessagesViewModel()

    let tabs = ["全部", "未读", "星标", "未分类"]

    var body: some View {
        VStack(spacing: 0) {
            // Tab 栏
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            viewModel.loadMessages(tab: index)
                        }) {
                            Text(tabs[index])
                                .font(.system(size: 14, weight: viewModel.currentTab == index ? .semibold : .regular))
                                .foregroundColor(viewModel.currentTab == index ? .sortisPrimary : .secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))

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
            .padding(.vertical, 8)

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
                    Text(emptyMessage)
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
                categories: viewModel.categories,
                onToggleRead: { viewModel.toggleRead(messageId: message.id) },
                onToggleStar: { viewModel.toggleStar(messageId: message.id) },
                onMove: { viewModel.moveMessage(messageId: message.id, categoryId: $0) },
                onDelete: { viewModel.deleteMessage(messageId: message.id) },
                onDismiss: { viewModel.setActionMessage(nil) }
            )
        }
    }

    private var emptyMessage: String {
        switch viewModel.currentTab {
        case 1: return "暂无未读信息"
        case 2: return "暂无星标信息"
        case 3: return "暂无未分类信息"
        default: return "暂无信息"
        }
    }
}