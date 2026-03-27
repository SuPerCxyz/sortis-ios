//
//  ViewViewModel.swift
//  Sortis
//
//  信息视图模型
//

import Foundation

@MainActor
class ViewViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var selectedCategory: Int?
    @Published var selectedCategoryName: String?
    @Published var timeRange: String = "7d"
    @Published var stats: MessageStats?
    @Published var selectedMessage: Message?
    @Published var actionMessage: Message?

    @Published var currentPage: Int = 1
    @Published var pageSize: Int = 20
    @Published var total: Int = 0
    @Published var totalPages: Int = 0

    @Published var allCategories: [Category] = []

    private let categoryService = CategoryService()
    private let messageService = MessageService()
    private let statsService = StatsService()

    init() {
        loadData()
    }

    func loadData(page: Int = 1) {
        Task {
            isLoading = true
            await fetchData(page: page)
            isLoading = false
        }
    }

    private func fetchData(page: Int) async {
        // 加载统计
        let days: Int? = {
            switch timeRange {
            case "1d": return 1
            case "3d": return 3
            case "7d": return 7
            case "30d": return 30
            default: return nil
            }
        }()

        do {
            let overview = try await statsService.getStatsOverview(days: days)
            stats = overview.messageStats
        } catch {
            print("Failed to load stats: \(error)")
        }

        // 加载分类树
        do {
            categories = try await categoryService.getCategoryTree(timeRange: timeRange)
        } catch {
            print("Failed to load categories: \(error)")
        }

        // 加载所有分类（用于移动分类对话框）
        do {
            allCategories = try await categoryService.getCategories()
        } catch {
            print("Failed to load all categories: \(error)")
        }

        // 加载消息
        do {
            let response = try await messageService.getMessages(
                page: page,
                pageSize: pageSize,
                categoryId: selectedCategory,
                timeRange: timeRange
            )
            messages = response.messages
            total = response.total
            totalPages = (total > 0) ? (total + pageSize - 1) / pageSize : 0
            currentPage = page
        } catch {
            print("Failed to load messages: \(error)")
        }
    }

    func refresh() {
        Task {
            isRefreshing = true
            await fetchData(page: currentPage)
            isRefreshing = false
        }
    }

    func selectCategory(categoryId: Int?, categoryName: String? = nil) {
        selectedCategory = categoryId
        selectedCategoryName = categoryName
        loadData(page: 1)
    }

    func clearSelectedCategory() {
        selectedCategory = nil
        selectedCategoryName = nil
        messages = []
    }

    func setTimeRange(_ range: String) {
        timeRange = range
        loadData(page: 1)
    }

    func selectMessage(_ message: Message?) {
        selectedMessage = message
        if let message = message {
            Task {
                // 标记已读
                if !message.isRead {
                    do {
                        let updated = try await messageService.markAsRead(messageId: message.id, isRead: true)
                        if let index = messages.firstIndex(where: { $0.id == message.id }) {
                            messages[index] = updated
                        }
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

    func changePage(_ page: Int) {
        loadData(page: page)
    }

    func changePageSize(_ size: Int) {
        pageSize = size
        loadData(page: 1)
    }

    func toggleRead(messageId: Int) {
        Task {
            guard let message = messages.first(where: { $0.id == messageId }) else { return }
            let targetRead = !message.isRead

            do {
                let updated = try await messageService.markAsRead(messageId: messageId, isRead: targetRead)
                if let index = messages.firstIndex(where: { $0.id == messageId }) {
                    messages[index] = updated
                }
                if selectedMessage?.id == messageId {
                    selectedMessage = updated
                }
                if actionMessage?.id == messageId {
                    actionMessage = updated
                }
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
                if let index = messages.firstIndex(where: { $0.id == messageId }) {
                    messages[index] = updated
                }
                if selectedMessage?.id == messageId {
                    selectedMessage = updated
                }
                if actionMessage?.id == messageId {
                    actionMessage = updated
                }
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
                loadData(page: currentPage)
            } catch {
                print("Failed to delete message: \(error)")
            }
        }
    }

    func moveMessage(messageId: Int, categoryId: Int) {
        Task {
            do {
                _ = try await messageService.moveMessage(messageId: messageId, categoryId: categoryId)
                loadData(page: currentPage)
                actionMessage = nil
            } catch {
                print("Failed to move message: \(error)")
            }
        }
    }

    func getAllFlatCategories() -> [FlatCategory] {
        return flattenCategories(allCategories)
    }
}