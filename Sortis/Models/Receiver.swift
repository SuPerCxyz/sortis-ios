//
//  Receiver.swift
//  Sortis
//
//  接收器数据模型
//

import Foundation

// 接收器
struct Receiver: Identifiable, Decodable {
    let id: Int
    let publicId: String?
    let name: String
    let type: String
    let config: AnyCodable?
    let status: String
    let isEnabled: Bool
    let messageCount: Int
    let lastSyncAt: String?
    let lastReceivedAt: String?
    let errorMessage: String?
    let syncInterval: Int?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, type, config, status
        case publicId = "public_id"
        case isEnabled = "is_enabled"
        case messageCount = "message_count"
        case lastSyncAt = "last_sync_at"
        case lastReceivedAt = "last_received_at"
        case errorMessage = "error_message"
        case syncInterval = "sync_interval"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        publicId = try container.decodeIfPresent(String.self, forKey: .publicId)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        config = try container.decodeIfPresent(AnyCodable.self, forKey: .config)
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "active"
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        messageCount = try container.decodeIfPresent(Int.self, forKey: .messageCount) ?? 0
        lastSyncAt = try container.decodeIfPresent(String.self, forKey: .lastSyncAt)
        lastReceivedAt = try container.decodeIfPresent(String.self, forKey: .lastReceivedAt)
        errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        syncInterval = try container.decodeIfPresent(Int.self, forKey: .syncInterval)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}

// 用于 Any 类型的 Decodable 包装
struct AnyCodable: Codable {
    let value: Any

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        }
    }
}

// 创建/更新接收器请求
struct ReceiverRequest: Encodable {
    let name: String
    let type: String
    let config: [String: AnyEncodable]?
    let syncInterval: Int?

    enum CodingKeys: String, CodingKey {
        case name, type, config
        case syncInterval = "sync_interval"
    }
}

// 验证接收器请求
struct ValidateReceiverRequest: Encodable {
    let type: String
    let config: [String: AnyEncodable]
}

// 接收器类型
enum ReceiverType: String, CaseIterable {
    case webhook = "http_token"
    case websocket = "websocket"
    case email = "email"
    case telegram = "telegram"
    case rss = "rss"

    var displayName: String {
        switch self {
        case .webhook: return "Webhook"
        case .websocket: return "WebSocket"
        case .email: return "邮箱"
        case .telegram: return "Telegram"
        case .rss: return "RSS"
        }
    }

    var description: String {
        switch self {
        case .webhook: return "通过 HTTP POST 接收消息"
        case .websocket: return "通过 WebSocket 长连接接收消息"
        case .email: return "通过 IMAP 协议拉取邮件"
        case .telegram: return "通过 Telegram Bot API 拉取消息"
        case .rss: return "订阅 RSS/Atom Feed 源"
        }
    }
}