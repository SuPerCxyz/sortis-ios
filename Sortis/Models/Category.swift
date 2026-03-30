//
//  Category.swift
//  Sortis
//
//  分类数据模型
//

import Foundation

// 分类
struct Category: Identifiable, Decodable {
    let id: Int
    let name: String
    let parentId: Int?
    let level: Int
    let sortOrder: Int
    let color: String?
    let icon: String?
    let iconUrl: String?
    let children: [Category]?
    let unreadCount: Int
    let totalCount: Int
    let readCount: Int
    let latestMessageTitle: String?
    let latestMessageTime: String?

    enum CodingKeys: String, CodingKey {
        case id, name, level, color, icon, children
        case parentId = "parent_id"
        case sortOrder = "sort_order"
        case iconUrl = "icon_url"
        case unreadCount = "unread_count"
        case totalCount = "total_count"
        case readCount = "read_count"
        case latestMessageTitle = "latest_message_title"
        case latestMessageTime = "latest_message_time"
    }
}

extension Category {
    func normalizedIconURL(serverUrl: String?) -> Category {
        Category(
            id: id,
            name: name,
            parentId: parentId,
            level: level,
            sortOrder: sortOrder,
            color: color,
            icon: icon,
            iconUrl: normalizeCategoryIconUrl(serverUrl: serverUrl, iconUrl: iconUrl),
            children: children?.map { $0.normalizedIconURL(serverUrl: serverUrl) },
            unreadCount: unreadCount,
            totalCount: totalCount,
            readCount: readCount,
            latestMessageTitle: latestMessageTitle,
            latestMessageTime: latestMessageTime
        )
    }
}

// 分类树响应
typealias CategoryTreeResponse = [Category]

// 用于创建/更新分类的请求
struct CategoryRequest: Encodable {
    let name: String
    let parentId: Int?
    let color: String?
    let icon: String?
    let iconUrl: String?

    enum CodingKeys: String, CodingKey {
        case name, color, icon
        case parentId = "parent_id"
        case iconUrl = "icon_url"
    }
}

// 分类排序请求
struct ReorderCategoriesRequest: Encodable {
    let parentId: Int?
    let orderedIds: [Int]

    enum CodingKeys: String, CodingKey {
        case orderedIds = "ordered_ids"
        case parentId = "parent_id"
    }
}

// 扁平化分类（用于列表显示）
struct FlatCategory: Identifiable {
    let id: Int
    let category: Category
    let indent: Int

    init(category: Category, indent: Int = 0) {
        self.id = category.id
        self.category = category
        self.indent = indent
    }
}

// 扁平化分类树
func flattenCategories(_ categories: [Category], indent: Int = 0) -> [FlatCategory] {
    var result: [FlatCategory] = []
    for cat in categories {
        result.append(FlatCategory(category: cat, indent: indent))
        if let children = cat.children, !children.isEmpty {
            result.append(contentsOf: flattenCategories(children, indent: indent + 1))
        }
    }
    return result
}

func normalizeCategoryIconUrl(serverUrl: String?, iconUrl: String?) -> String? {
    guard let iconUrl, !iconUrl.isEmpty else { return nil }

    let normalizedPath: String
    if iconUrl.hasPrefix("/api/attachments/file/") {
        normalizedPath = iconUrl.replacingOccurrences(of: "/api/attachments/file/", with: "/public/attachments/file/")
    } else {
        normalizedPath = iconUrl
    }

    if normalizedPath.hasPrefix("http://") || normalizedPath.hasPrefix("https://") {
        return normalizedPath
    }

    let trimmedBase = serverUrl?.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/")) ?? ""
    return trimmedBase.isEmpty ? normalizedPath : "\(trimmedBase)\(normalizedPath)"
}
