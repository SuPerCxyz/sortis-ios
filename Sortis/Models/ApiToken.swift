//
//  ApiToken.swift
//  Sortis
//
//  API Token 数据模型
//

import Foundation

// API Token
struct ApiToken: Identifiable, Decodable {
    let id: Int
    let name: String
    let tokenPreview: String?
    let plainToken: String?
    let receiverId: Int?
    let receiverIds: [Int]?
    let receiverNames: [String]?
    let isActive: Bool
    let status: String?
    let isExpired: Bool?
    let expiresAt: String?
    let lastUsedAt: String?
    let createdAt: String?

    // Computed property for display
    var token: String {
        return plainToken ?? tokenPreview ?? ""
    }

    var runtimeStatus: String {
        if status == "expired" || isExpired == true {
            return "expired"
        }
        if status == "paused" {
            return "paused"
        }
        if status == "active" {
            return "active"
        }
        return isActive ? "active" : "paused"
    }

    var statusText: String {
        switch runtimeStatus {
        case "active":
            return "运行中"
        case "paused":
            return "已暂停"
        case "expired":
            return "已过期"
        default:
            return runtimeStatus
        }
    }

    var isUsable: Bool {
        runtimeStatus == "active"
    }

    var canToggleAction: Bool {
        runtimeStatus != "expired"
    }

    var toggleActionLabel: String {
        runtimeStatus == "paused" ? "恢复" : "暂停"
    }

    var toggleActionSystemImage: String {
        runtimeStatus == "paused" ? "play.fill" : "pause.fill"
    }

    enum CodingKeys: String, CodingKey {
        case id, name
        case tokenPreview = "token_preview"
        case plainToken = "plain_token"
        case receiverId = "receiver_id"
        case receiverIds = "receiver_ids"
        case receiverNames = "receiver_names"
        case isActive = "is_active"
        case status
        case isExpired = "is_expired"
        case expiresAt = "expires_at"
        case lastUsedAt = "last_used_at"
        case createdAt = "created_at"
    }
}

// Token 创建响应
struct TokenCreateResponse: Decodable {
    let id: Int
    let name: String
    let tokenPreview: String?
    let plainToken: String?
    let receiverId: Int?
    let receiverIds: [Int]?
    let receiverNames: [String]?
    let expiresAt: String?
    let isActive: Bool
    let status: String?
    let isExpired: Bool?
    let lastUsedAt: String?
    let createdAt: String?
    let token: String

    enum CodingKeys: String, CodingKey {
        case id, name, token
        case tokenPreview = "token_preview"
        case plainToken = "plain_token"
        case receiverId = "receiver_id"
        case receiverIds = "receiver_ids"
        case receiverNames = "receiver_names"
        case expiresAt = "expires_at"
        case isActive = "is_active"
        case status
        case isExpired = "is_expired"
        case lastUsedAt = "last_used_at"
        case createdAt = "created_at"
    }
}

// 创建 Token 请求
struct TokenCreateRequest: Encodable {
    let name: String
    let receiverIds: [Int]?
    let expiresInDays: Int?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case name, description
        case receiverIds = "receiver_ids"
        case expiresInDays = "expires_in_days"
    }
}

// 更新 Token 请求
struct TokenUpdateRequest: Encodable {
    let name: String
}

// 绑定 Token 到接收器请求
struct BindTokenRequest: Encodable {
    let receiverId: Int?
    let receiverIds: [Int]?

    enum CodingKeys: String, CodingKey {
        case receiverId = "receiver_id"
        case receiverIds = "receiver_ids"
    }
}
