//
//  MessageService.swift
//  Sortis
//
//  消息服务
//

import Foundation

class MessageService {
    private let client = APIClient.shared

    // 获取消息列表
    func getMessages(
        page: Int = 1,
        pageSize: Int = 100,
        categoryId: Int? = nil,
        timeRange: String? = nil,
        isRead: Bool? = nil,
        search: String? = nil
    ) async throws -> MessageListResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize))
        ]

        if let categoryId = categoryId {
            queryItems.append(URLQueryItem(name: "category_id", value: String(categoryId)))
        }
        if let timeRange = timeRange {
            queryItems.append(URLQueryItem(name: "time_range", value: timeRange))
        }
        if let isRead = isRead {
            queryItems.append(URLQueryItem(name: "is_read", value: String(isRead)))
        }
        if let search = search {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }

        return try await client.get(path: "/api/messages", queryItems: queryItems)
    }

    // 获取所有消息（分页加载）
    func getAllMessages(categoryId: Int? = nil, timeRange: String? = nil, pageSize: Int = 10000) async throws -> [Message] {
        var allMessages: [Message] = []
        var page = 1
        var hasMore = true

        while hasMore {
            let response = try await getMessages(
                page: page,
                pageSize: pageSize,
                categoryId: categoryId,
                timeRange: timeRange
            )
            allMessages.append(contentsOf: response.messages)

            hasMore = response.messages.count == pageSize && page < 100
            page += 1
        }

        return allMessages
    }

    // 获取消息详情
    func getMessage(messageId: Int) async throws -> Message {
        return try await client.get(path: "/api/messages/\(messageId)")
    }

    // 更新消息
    func updateMessage(messageId: Int, request: MessageUpdateRequest) async throws -> Message {
        return try await client.put(path: "/api/messages/\(messageId)", body: request)
    }

    // 标记已读/未读
    func markAsRead(messageId: Int, isRead: Bool) async throws -> Message {
        let request = MessageUpdateRequest(title: nil, content: nil, isRead: isRead, isStarred: nil, isDeleted: nil)
        return try await updateMessage(messageId: messageId, request: request)
    }

    // 切换星标
    func toggleStar(messageId: Int, isStarred: Bool) async throws -> Message {
        let request = MessageUpdateRequest(title: nil, content: nil, isRead: nil, isStarred: isStarred, isDeleted: nil)
        return try await updateMessage(messageId: messageId, request: request)
    }

    // 删除消息
    func deleteMessage(messageId: Int) async throws -> Bool {
        return try await client.delete(path: "/api/messages/\(messageId)")
    }

    // 移动消息到分类
    func moveMessage(messageId: Int, categoryId: Int) async throws -> Bool {
        guard let url = client.buildURL?(path: "/api/messages/bulk-move?category_id=\(categoryId)") else {
            throw APIError.invalidURL
        }

        let body = [messageId]
        let bodyData = try JSONEncoder().encode(body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = bodyData

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        return httpResponse.statusCode == 200
    }
}