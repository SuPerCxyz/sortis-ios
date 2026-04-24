//
//  AllMessagesView.swift
//  Sortis
//
//  所有消息视图
//

import SwiftUI

struct AllMessagesView: View {
    @StateObject private var viewModel = AllMessagesViewModel()

    let tabs = ["全部", "未读", "已读", "星标", "未分类"]

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

            HStack(spacing: 8) {
                Menu {
                    ForEach(messageSearchFieldOptions) { option in
                        Button(action: {
                            viewModel.setSearch(query: viewModel.searchQuery, field: option.value)
                        }) {
                            if viewModel.searchField == option.value {
                                Label(option.label, systemImage: "checkmark")
                            } else {
                                Text(option.label)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(searchFieldLabel(for: viewModel.searchField, options: messageSearchFieldOptions))
                            .font(.caption)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
                SortisSearchIcon(size: 16, color: .secondary)
                TextField("", text: $viewModel.searchQuery)
                    .sortisCenteredPlaceholder("搜索信息", isEmpty: viewModel.searchQuery.isEmpty)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit {
                        viewModel.setSearch(query: viewModel.searchQuery, field: viewModel.searchField)
                    }
                if !viewModel.searchQuery.isEmpty {
                    Button("搜索") {
                        viewModel.setSearch(query: viewModel.searchQuery, field: viewModel.searchField)
                    }
                    .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .cornerRadius(10)
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
                    Text(emptyMessage)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            MessageEntityCard(message: message) {
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
            MessageEntityDetailSheet(
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
                onDelete: { deleteRemote in
                    viewModel.deleteMessage(messageId: message.id, deleteRemote: deleteRemote)
                },
                onDismiss: { viewModel.setActionMessage(nil) }
            )
        }
    }

    private var emptyMessage: String {
        switch viewModel.currentTab {
        case 1: return "暂无未读信息"
        case 2: return "暂无已读信息"
        case 3: return "暂无星标信息"
        case 4: return "暂无未分类信息"
        default: return "暂无信息"
        }
    }
}
