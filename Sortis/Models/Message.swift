//
//  Message.swift
//  Sortis
//
//  消息数据模型
//

import Foundation

// 消息
struct Message: Identifiable, Decodable {
    let id: Int
    let userId: Int
    let receiverId: Int?
    let sourceName: String?
    let sourceAddress: String?
    let title: String?
    let content: String?
    let contentType: String?
    let isRead: Bool
    let isStarred: Bool
    let isCategorized: Bool
    let receivedAt: String
    let createdAt: String?
    let hasFullContent: Bool
    let attachments: [Attachment]?
    let receiver: ReceiverInfo?
    let categories: [CategoryInfo]?

    enum CodingKeys: String, CodingKey {
        case id, title, content, receiver, categories
        case userId = "user_id"
        case receiverId = "receiver_id"
        case sourceName = "source_name"
        case sourceAddress = "source_address"
        case contentType = "content_type"
        case isRead = "is_read"
        case isStarred = "is_starred"
        case isCategorized = "is_categorized"
        case receivedAt = "received_at"
        case createdAt = "created_at"
        case hasFullContent = "has_full_content"
        case attachments
    }

    init(
        id: Int,
        userId: Int,
        receiverId: Int?,
        sourceName: String?,
        sourceAddress: String?,
        title: String?,
        content: String?,
        contentType: String?,
        isRead: Bool,
        isStarred: Bool,
        isCategorized: Bool,
        receivedAt: String,
        createdAt: String?,
        hasFullContent: Bool = true,
        attachments: [Attachment]?,
        receiver: ReceiverInfo?,
        categories: [CategoryInfo]?
    ) {
        self.id = id
        self.userId = userId
        self.receiverId = receiverId
        self.sourceName = sourceName
        self.sourceAddress = sourceAddress
        self.title = title
        self.content = content
        self.contentType = contentType
        self.isRead = isRead
        self.isStarred = isStarred
        self.isCategorized = isCategorized
        self.receivedAt = receivedAt
        self.createdAt = createdAt
        self.hasFullContent = hasFullContent
        self.attachments = attachments
        self.receiver = receiver
        self.categories = categories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        receiverId = try container.decodeIfPresent(Int.self, forKey: .receiverId)
        sourceName = try container.decodeIfPresent(String.self, forKey: .sourceName)
        sourceAddress = try container.decodeIfPresent(String.self, forKey: .sourceAddress)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        contentType = try container.decodeIfPresent(String.self, forKey: .contentType)
        isRead = try container.decode(Bool.self, forKey: .isRead)
        isStarred = try container.decode(Bool.self, forKey: .isStarred)
        isCategorized = try container.decode(Bool.self, forKey: .isCategorized)
        receivedAt = try container.decode(String.self, forKey: .receivedAt)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        hasFullContent = try container.decodeIfPresent(Bool.self, forKey: .hasFullContent) ?? true
        attachments = try container.decodeIfPresent([Attachment].self, forKey: .attachments)
        receiver = try container.decodeIfPresent(ReceiverInfo.self, forKey: .receiver)
        categories = try container.decodeIfPresent([CategoryInfo].self, forKey: .categories)
    }
}

// 附件
struct Attachment: Decodable {
    let id: Int
    let filename: String
    let contentType: String?
    let size: Int
    let isInline: Bool
    let cid: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, filename, size, cid
        case contentType = "content_type"
        case isInline = "is_inline"
        case createdAt = "created_at"
    }
}

// 接收器信息
struct ReceiverInfo: Decodable {
    let id: Int
    let name: String
    let type: String
}

// 分类信息
struct CategoryInfo: Decodable {
    let id: Int
    let name: String
    let color: String?
}

// 消息列表响应
struct MessageListResponse: Decodable {
    let total: Int
    let messages: [Message]
}

// 消息更新请求
struct MessageUpdateRequest: Encodable {
    let title: String?
    let content: String?
    let isRead: Bool?
    let isStarred: Bool?
    let isDeleted: Bool?

    enum CodingKeys: String, CodingKey {
        case title, content
        case isRead = "is_read"
        case isStarred = "is_starred"
        case isDeleted = "is_deleted"
    }
}

// 批量移动消息请求
struct BulkMoveRequest: Encodable {
    // 空请求体，categoryId 通过 query 参数传递
}

// 消息统计
struct MessageStats: Decodable {
    let total: Int
    let unread: Int
    let read: Int
    let starred: Int
}

// 统计概览响应
struct StatsOverviewResponse: Decodable {
    let messageStats: MessageStats
    let receiverStats: [ReceiverStat]

    enum CodingKeys: String, CodingKey {
        case messageStats = "message_stats"
        case receiverStats = "receiver_stats"
    }
}

struct ReceiverStat: Decodable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let status: String
    let errorMessage: String?
    let lastSyncAt: String?
    let messageCount: Int

    enum CodingKeys: String, CodingKey {
        case id, name, type, status
        case errorMessage = "error_message"
        case lastSyncAt = "last_sync_at"
        case messageCount = "message_count"
    }
}

// 活跃度统计响应
struct ActivityStatsResponse: Decodable {
    let daily: [ActivityDailyStat]
    let summary: ActivitySummary
}

// 每日活跃统计
struct ActivityDailyStat: Decodable {
    let date: String
    let messageCount: Int
    let readCount: Int

    enum CodingKeys: String, CodingKey {
        case date
        case messageCount = "message_count"
        case readCount = "read_count"
    }
}

// 活跃度汇总
struct ActivitySummary: Decodable {
    let totalMessages: Int
    let totalRead: Int
    let readRate: Double

    enum CodingKeys: String, CodingKey {
        case totalMessages = "total_messages"
        case totalRead = "total_read"
        case readRate = "read_rate"
    }
}

// 分类统计项
struct CategoryStatsItem: Decodable {
    let id: Int
    let name: String
    let fullPath: String
    let level: Int
    let messageCount: Int
    let unreadCount: Int

    enum CodingKeys: String, CodingKey {
        case id, name, level
        case fullPath = "full_path"
        case messageCount = "message_count"
        case unreadCount = "unread_count"
    }
}

struct SearchFieldOption: Identifiable, Hashable {
    let value: String
    let label: String

    var id: String { value }
}

let messageSearchFieldOptions: [SearchFieldOption] = [
    SearchFieldOption(value: "all", label: "全部字段"),
    SearchFieldOption(value: "title", label: "标题"),
    SearchFieldOption(value: "content", label: "内容"),
    SearchFieldOption(value: "receiver", label: "接收器"),
    SearchFieldOption(value: "category", label: "分类"),
]

let receiverSearchFieldOptions: [SearchFieldOption] = [
    SearchFieldOption(value: "all", label: "全部字段"),
    SearchFieldOption(value: "name", label: "名称"),
    SearchFieldOption(value: "type", label: "类型"),
    SearchFieldOption(value: "status", label: "状态"),
    SearchFieldOption(value: "token", label: "Token"),
]

let ruleSearchFieldOptions: [SearchFieldOption] = [
    SearchFieldOption(value: "all", label: "全部字段"),
    SearchFieldOption(value: "name", label: "规则名称"),
    SearchFieldOption(value: "description", label: "描述"),
    SearchFieldOption(value: "category", label: "目标分类"),
    SearchFieldOption(value: "match_type", label: "匹配模式"),
    SearchFieldOption(value: "template", label: "模板"),
    SearchFieldOption(value: "condition", label: "匹配条件"),
]

let tokenSearchFieldOptions: [SearchFieldOption] = [
    SearchFieldOption(value: "all", label: "全部字段"),
    SearchFieldOption(value: "name", label: "Token 名称"),
    SearchFieldOption(value: "preview", label: "预览值"),
    SearchFieldOption(value: "receiver", label: "绑定接收器"),
    SearchFieldOption(value: "status", label: "状态"),
]

func searchFieldLabel(for value: String, options: [SearchFieldOption]) -> String {
    options.first(where: { $0.value == value })?.label ?? options.first?.label ?? "全部字段"
}
