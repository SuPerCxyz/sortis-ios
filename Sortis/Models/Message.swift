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
        case attachments
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

    enum CodingKeys: String, CodingKey {
        case messageStats = "message_stats"
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