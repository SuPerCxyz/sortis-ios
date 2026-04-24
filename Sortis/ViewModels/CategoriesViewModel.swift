//
//  CategoriesViewModel.swift
//  Sortis
//
//  分类管理视图模型
//

import Foundation

@MainActor
class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var flatCategories: [FlatCategory] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var error: String?

    @Published var editCategory: Category?
    @Published var actionCategory: Category?
    @Published var isCreateOpen: Bool = false
    @Published var moveCategoryTarget: Category?
    @Published var selectedCategory: Category?
    @Published var messages: [Message] = []
    @Published var selectedMessage: Message?
    @Published var actionMessage: Message?
    @Published var currentPage: Int = 1
    @Published var pageSize: Int = 20
    @Published var total: Int = 0
    @Published var totalPages: Int = 0
    @Published var timeRange: String = "7d"
    @Published var messageStatusFilter: String = "all"
    @Published var searchQuery: String = ""
    @Published var searchField: String = "all"

    private let categoryService = CategoryService()
    private let messageService = MessageService()

    init() {
        loadCategories()
    }

    func loadCategories() {
        Task {
            isLoading = true
            error = nil
            do {
                categories = try await categoryService.getCategories()
                flatCategories = flattenCategories(categories)
                if let selectedCategory {
                    self.selectedCategory = findCategory(categories, categoryId: selectedCategory.id)
                }
            } catch let err {
                error = err.localizedDescription
            }
            isLoading = false
        }
    }

    func refresh() {
        Task {
            isRefreshing = true
            error = nil
            do {
                categories = try await categoryService.getCategories()
                flatCategories = flattenCategories(categories)
                if selectedCategory != nil {
                    if let selectedCategory {
                        self.selectedCategory = findCategory(categories, categoryId: selectedCategory.id)
                    }
                    await fetchMessages(page: currentPage)
                }
            } catch let err {
                error = err.localizedDescription
            }
            isRefreshing = false
        }
    }

    func setCreateOpen(_ open: Bool) {
        isCreateOpen = open
    }

    func setMoveCategoryTarget(_ category: Category?) {
        moveCategoryTarget = category
    }

    func setEditCategory(_ category: Category?) {
        editCategory = category
    }

    func setActionCategory(_ category: Category?) {
        actionCategory = category
    }

    func createCategory(name: String, parentId: Int?, color: String?, icon: String?, iconUrl: String?) {
        Task {
            do {
                _ = try await categoryService.createCategory(name: name, parentId: parentId, color: color, icon: icon, iconUrl: iconUrl)
                isCreateOpen = false
                loadCategories()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func updateCategory(categoryId: Int, name: String, parentId: Int?, color: String?, icon: String?, iconUrl: String?) {
        Task {
            do {
                _ = try await categoryService.updateCategory(categoryId: categoryId, name: name, parentId: parentId, color: color, icon: icon, iconUrl: iconUrl)
                editCategory = nil
                loadCategories()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func deleteCategory(categoryId: Int) {
        Task {
            do {
                _ = try await categoryService.deleteCategory(categoryId: categoryId)
                actionCategory = nil
                loadCategories()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func moveCategory(categoryId: Int, moveUp: Bool) {
        Task {
            guard let category = findCategory(categories, categoryId: categoryId) else { return }
            let siblingIds = findSiblingIds(categories, parentId: category.parentId)
            guard let currentIndex = siblingIds.firstIndex(of: categoryId) else { return }

            let swapIndex = moveUp ? currentIndex - 1 : currentIndex + 1
            guard swapIndex >= 0 && swapIndex < siblingIds.count else { return }

            var reorderedIds = siblingIds
            reorderedIds.swapAt(currentIndex, swapIndex)

            do {
                _ = try await categoryService.reorderCategories(parentId: category.parentId, orderedIds: reorderedIds)
                actionCategory = nil
                loadCategories()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func moveCategory(categoryId: Int, toParentId parentId: Int?) {
        Task {
            guard let category = findCategory(categories, categoryId: categoryId) else { return }
            do {
                _ = try await categoryService.updateCategory(
                    categoryId: categoryId,
                    name: category.name,
                    parentId: parentId,
                    color: category.color,
                    icon: category.icon,
                    iconUrl: category.iconUrl
                )
                moveCategoryTarget = nil
                loadCategories()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func selectCategory(_ category: Category) {
        selectedCategory = category
        currentPage = 1
        Task {
            isLoading = true
            await fetchMessages(page: 1)
            isLoading = false
        }
    }

    func clearSelectedCategory() {
        selectedCategory = nil
        messages = []
        selectedMessage = nil
        actionMessage = nil
    }

    func changePage(_ page: Int) {
        Task {
            isLoading = true
            await fetchMessages(page: page)
            isLoading = false
        }
    }

    func setTimeRange(_ range: String) {
        timeRange = range
        changePage(1)
    }

    func setMessageStatusFilter(_ value: String) {
        messageStatusFilter = value
        changePage(1)
    }

    func setSearchQuery(_ value: String) {
        setSearch(query: value, field: searchField)
    }

    func setSearch(query: String, field: String) {
        let previousQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let nextQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let previousField = searchField
        searchQuery = query
        searchField = field

        let queryChanged = previousQuery != nextQuery
        let shouldReloadForFieldChange = !nextQuery.isEmpty && previousField != field
        guard queryChanged || shouldReloadForFieldChange else { return }

        changePage(1)
    }

    func selectMessage(_ message: Message?) {
        selectedMessage = message
        guard let message else { return }

        Task {
            let optimistic = Message(
                id: message.id,
                userId: message.userId,
                receiverId: message.receiverId,
                sourceName: message.sourceName,
                sourceAddress: message.sourceAddress,
                title: message.title,
                content: message.content,
                contentType: message.contentType,
                isRead: true,
                isStarred: message.isStarred,
                isCategorized: message.isCategorized,
                receivedAt: message.receivedAt,
                createdAt: message.createdAt,
                hasFullContent: message.hasFullContent,
                attachments: message.attachments,
                receiver: message.receiver,
                categories: message.categories
            )
            updateMessageInList(optimistic)
            selectedMessage = optimistic

            do {
                let updated: Message
                if !message.isRead {
                    updated = try await messageService.markAsRead(messageId: message.id, isRead: true)
                } else if !message.hasFullContent {
                    updated = try await messageService.getMessage(messageId: message.id)
                } else {
                    updated = optimistic
                }
                updateMessageInList(updated)
                selectedMessage = updated
            } catch {
                self.error = error.localizedDescription
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
                self.error = error.localizedDescription
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
                self.error = error.localizedDescription
            }
        }
    }

    func deleteMessage(messageId: Int, deleteRemote: Bool = false) {
        Task {
            do {
                _ = try await messageService.deleteMessage(messageId: messageId, deleteRemote: deleteRemote)
                messages.removeAll { $0.id == messageId }
                actionMessage = nil
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    func moveMessage(messageId: Int, categoryId: Int) {
        Task {
            do {
                _ = try await messageService.moveMessage(messageId: messageId, categoryId: categoryId)
                actionMessage = nil
                await fetchMessages(page: currentPage)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    private func findCategory(_ categories: [Category], categoryId: Int) -> Category? {
        for cat in categories {
            if cat.id == categoryId { return cat }
            if let found = findCategory(cat.children ?? [], categoryId: categoryId) { return found }
        }
        return nil
    }

    private func findSiblingIds(_ categories: [Category], parentId: Int?) -> [Int] {
        let siblings = categories.filter { $0.parentId == parentId }
        if !siblings.isEmpty { return siblings.map { $0.id } }
        for cat in categories {
            let nested = findSiblingIds(cat.children ?? [], parentId: parentId)
            if !nested.isEmpty { return nested }
        }
        return []
    }

    func canMoveUp(_ category: Category) -> Bool {
        let siblingIds = findSiblingIds(categories, parentId: category.parentId)
        guard let index = siblingIds.firstIndex(of: category.id) else { return false }
        return index > 0
    }

    func canMoveDown(_ category: Category) -> Bool {
        let siblingIds = findSiblingIds(categories, parentId: category.parentId)
        guard let index = siblingIds.firstIndex(of: category.id) else { return false }
        return index < siblingIds.count - 1
    }

    private func flattenCategories(_ categories: [Category], indent: Int = 0) -> [FlatCategory] {
        var result: [FlatCategory] = []
        for category in categories {
            result.append(FlatCategory(category: category, indent: indent))
            if let children = category.children, !children.isEmpty {
                result.append(contentsOf: flattenCategories(children, indent: indent + 1))
            }
        }
        return result
    }

    func moveParentCandidates(for category: Category) -> [FlatCategory] {
        let blockedIds = Set([category.id] + descendantIds(for: category))
        return flatCategories.filter { !blockedIds.contains($0.id) }
    }

    func getAllFlatCategories() -> [FlatCategory] {
        flatCategories
    }

    private func descendantIds(for category: Category) -> [Int] {
        var ids: [Int] = []
        for child in category.children ?? [] {
            ids.append(child.id)
            ids.append(contentsOf: descendantIds(for: child))
        }
        return ids
    }

    private func fetchMessages(page: Int) async {
        guard let selectedCategory else { return }
        do {
            let isRead: Bool? = {
                switch messageStatusFilter {
                case "unread": return false
                case "read": return true
                default: return nil
                }
            }()
            let isStarred: Bool? = messageStatusFilter == "starred" ? true : nil
            let isCategorized: Bool? = messageStatusFilter == "uncategorized" ? false : nil
            let response = try await messageService.getMessages(
                page: page,
                pageSize: pageSize,
                categoryId: selectedCategory.id,
                timeRange: timeRange,
                isRead: isRead,
                isStarred: isStarred,
                isCategorized: isCategorized,
                search: searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : searchQuery,
                searchField: searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : searchField
            )
            messages = response.messages
            total = response.total
            totalPages = total > 0 ? (total + pageSize - 1) / pageSize : 0
            currentPage = min(page, max(1, totalPages == 0 ? 1 : totalPages))
        } catch {
            self.error = error.localizedDescription
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
