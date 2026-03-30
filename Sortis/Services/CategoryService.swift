//
//  CategoryService.swift
//  Sortis
//
//  分类服务
//

import Foundation

class CategoryService {
    private let client = APIClient.shared
    private var serverUrl: String? {
        UserDefaults.standard.string(forKey: "serverUrl")
    }

    // 获取分类列表
    func getCategories() async throws -> [Category] {
        let categories: [Category] = try await client.get(path: "/api/categories")
        return categories.map { $0.normalizedIconURL(serverUrl: serverUrl) }
    }

    // 获取分类树
    func getCategoryTree(timeRange: String? = nil) async throws -> [Category] {
        var queryItems: [URLQueryItem] = []
        if let timeRange = timeRange {
            queryItems.append(URLQueryItem(name: "time_range", value: timeRange))
        }
        let categories: [Category] = try await client.get(path: "/api/categories/tree", queryItems: queryItems.isEmpty ? nil : queryItems)
        return categories.map { $0.normalizedIconURL(serverUrl: serverUrl) }
    }

    // 创建分类
    func createCategory(name: String, parentId: Int?, color: String?, icon: String?, iconUrl: String?) async throws -> Category {
        let request = CategoryRequest(name: name, parentId: parentId, color: color, icon: icon, iconUrl: iconUrl)
        return try await client.post(path: "/api/categories", body: request)
    }

    // 更新分类
    func updateCategory(categoryId: Int, name: String, parentId: Int?, color: String?, icon: String?, iconUrl: String?) async throws -> Category {
        let request = CategoryRequest(name: name, parentId: parentId, color: color, icon: icon, iconUrl: iconUrl)
        return try await client.put(path: "/api/categories/\(categoryId)", body: request)
    }

    // 删除分类
    func deleteCategory(categoryId: Int) async throws -> Bool {
        return try await client.delete(path: "/api/categories/\(categoryId)")
    }

    // 重排序分类
    func reorderCategories(parentId: Int?, orderedIds: [Int]) async throws -> [Category] {
        let request = ReorderCategoriesRequest(parentId: parentId, orderedIds: orderedIds)
        return try await client.put(path: "/api/categories/reorder", body: request)
    }
}
