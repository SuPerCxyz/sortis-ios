//
//  AllMessagesViewModel.swift
//  Sortis
//
//  所有消息视图模型
//

import Foundation

@MainActor
class AllMessagesViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var currentTab: Int = 0
    @Published var timeRange: String = "7d"
    @Published var selectedMessage: Message?
    @Published var actionMessage: Message?
    @Published var showMoveDialog: Bool = false

    @Published var currentPage: Int = 1
    @Published var pageSize: Int = 20
    @Published var total: Int = 0
    @Published var totalPages: Int = 0

    @Published var categories: [FlatCategory] = []

    private var allMessages: [Message] = []

    private let messageService = MessageService()
    private let categoryService = CategoryService()

    init() {
        loadCategories()
    }

    func loadCategories() {
        Task {
            do {
                let cats = try await categoryService.getCategories()
                categories = flattenCategories(cats)
            } catch {
                print("Failed to load categories: \(error)")
            }
        }
    }

    func loadMessages(tab: Int = 0, page: Int = 1, pageSize: Int = 20) {
        currentTab = tab
        Task {
            isLoading = true
            await fetchMessages(tab: tab, page: page, pageSize: pageSize)
            isLoading = false
        }
    }

    private func fetchMessages(tab: Int, page: Int, pageSize: Int) async {
        do {
            allMessages = try await messageService.getAllMessages(timeRange: timeRange)

            // 按时间排序
            let sortedMessages = allMessages.sorted { $0.receivedAt > $1.receivedAt }

            // 根据标签过滤
            let filtered: [Message]
            switch tab {
            case 1:
                filtered = sortedMessages.filter { !$0.isRead }
            case 2:
                filtered = sortedMessages.filter { $0.isStarred }
            case 3:
                filtered = sortedMessages.filter { $0.categories?.isEmpty ?? true }
            default:
                filtered = sortedMessages
            }

            total = filtered.count
            totalPages = (total > 0) ? (total + pageSize - 1) / pageSize : 0

            let safePage = min(page, max(1, totalPages))
            let startIndex = (safePage - 1) * pageSize
            let endIndex = min(startIndex + pageSize, total)

            messages = startIndex < total ? Array(filtered[startIndex..<endIndex]) : []
            currentPage = safePage
        } catch {
            print("Failed to load messages: \(error)")
        }
    }

    func refresh() {
        Task {
            isRefreshing = true
            await fetchMessages(tab: currentTab, page: currentPage, pageSize: pageSize)
            isRefreshing = false
        }
    }

    func changePage(_ page: Int) {
        loadMessages(tab: currentTab, page: page, pageSize: pageSize)
    }

    func changePageSize(_ size: Int) {
        loadMessages(tab: currentTab, page: 1, pageSize: size)
    }

    func setTimeRange(_ range: String) {
        timeRange = range
        loadMessages(tab: currentTab, page: 1, pageSize: pageSize)
    }

    func selectMessage(_ message: Message?) {
        selectedMessage = message
        if let message = message {
            Task {
                if !message.isRead {
                    do {
                        let updated = try await messageService.markAsRead(messageId: message.id, isRead: true)
                        updateMessageInList(updated)
                        selectedMessage = updated
                    } catch {
                        print("Failed to mark as read: \(error)")
                    }
                }
            }
        }
    }

    func setActionMessage(_ message: Message?) {
        actionMessage = message
    }

    func toggleRead(messageId: Int) {
        Task {
            guard let message = messages.first(where: { $0.id == messageId }) else { return }
            do {
                let updated = try await messageService.markAsRead(messageId: messageId, isRead: !message.isRead)
                updateMessageInList(updated)
            } catch {
                print("Failed to toggle read: \(error)")
            }
        }
    }

    func toggleStar(messageId: Int) {
        Task {
            guard let message = messages.first(where: { $0.id == messageId }) else { return }
            do {
                let updated = try await messageService.toggleStar(messageId: messageId, isStarred: !message.isStarred)
                updateMessageInList(updated)
            } catch {
                print("Failed to toggle star: \(error)")
            }
        }
    }

    func deleteMessage(messageId: Int) {
        Task {
            do {
                _ = try await messageService.deleteMessage(messageId: messageId)
                messages.removeAll { $0.id == messageId }
                actionMessage = nil
            } catch {
                print("Failed to delete message: \(error)")
            }
        }
    }

    func moveMessage(messageId: Int, categoryId: Int) {
        Task {
            do {
                _ = try await messageService.moveMessage(messageId: messageId, categoryId: categoryId)
                loadMessages(tab: currentTab, page: currentPage, pageSize: pageSize)
                actionMessage = nil
                showMoveDialog = false
            } catch {
                print("Failed to move message: \(error)")
            }
        }
    }

    private func updateMessageInList(_ updated: Message) {
        if let index = messages.firstIndex(where: { $0.id == updated.id }) {
            messages[index] = updated
        }
        if selectedMessage?.id == updated.id {
            selectedMessage = updated
        }
        if actionMessage?.id == updated.id {
            actionMessage = updated
        }
    }
}