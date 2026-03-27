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

    private let categoryService = CategoryService()

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
            } catch let err {
                error = err.localizedDescription
            }
            isRefreshing = false
        }
    }

    func setCreateOpen(_ open: Bool) {
        isCreateOpen = open
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
}