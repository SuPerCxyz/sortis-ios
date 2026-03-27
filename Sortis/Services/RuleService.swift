//
//  RuleService.swift
//  Sortis
//
//  规则服务
//

import Foundation

class RuleService {
    private let client = APIClient.shared

    // 获取规则列表
    func getRules(categoryId: Int? = nil) async throws -> RuleListResponse {
        var queryItems: [URLQueryItem] = []
        if let categoryId = categoryId {
            queryItems.append(URLQueryItem(name: "category_id", value: String(categoryId)))
        }
        return try await client.get(path: "/api/rules", queryItems: queryItems.isEmpty ? nil : queryItems)
    }

    // 获取规则详情
    func getRule(ruleId: Int) async throws -> Rule {
        return try await client.get(path: "/api/rules/\(ruleId)")
    }

    // 创建规则
    func createRule(
        name: String,
        description: String?,
        categoryId: Int,
        priority: Int,
        conditions: [String: AnyEncodable],
        isEnabled: Bool
    ) async throws -> Rule {
        var body: [String: AnyEncodable] = [
            "name": AnyEncodable(name),
            "category_id": AnyEncodable(categoryId),
            "priority": AnyEncodable(priority),
            "conditions": AnyEncodable(conditions),
            "is_enabled": AnyEncodable(isEnabled)
        ]
        if let description = description {
            body["description"] = AnyEncodable(description)
        }

        return try await client.post(path: "/api/rules", body: body)
    }

    // 更新规则
    func updateRule(
        ruleId: Int,
        name: String,
        description: String?,
        categoryId: Int?,
        priority: Int,
        conditions: [String: AnyEncodable]?,
        isEnabled: Bool?
    ) async throws -> Rule {
        var body: [String: AnyEncodable] = [
            "name": AnyEncodable(name),
            "priority": AnyEncodable(priority)
        ]
        if let description = description {
            body["description"] = AnyEncodable(description)
        }
        if let categoryId = categoryId {
            body["category_id"] = AnyEncodable(categoryId)
        }
        if let conditions = conditions {
            body["conditions"] = AnyEncodable(conditions)
        }
        if let isEnabled = isEnabled {
            body["is_enabled"] = AnyEncodable(isEnabled)
        }

        return try await client.put(path: "/api/rules/\(ruleId)", body: body)
    }

    // 切换规则状态
    func toggleRule(ruleId: Int) async throws -> Rule {
        return try await client.post(path: "/api/rules/\(ruleId)/toggle", body: Optional<Never>.none as Never?)
    }

    // 删除规则
    func deleteRule(ruleId: Int) async throws -> Bool {
        return try await client.delete(path: "/api/rules/\(ruleId)")
    }

    // 重新分类响应
struct RecategorizeResponse: Decodable {
    let processed: Int
    let message: String?
}

    // 重新分类
    func recategorizeRules(categoryIds: [Int]? = nil) async throws -> RecategorizeResponse {
        var body: [String: AnyEncodable] = [:]
        if let categoryIds = categoryIds {
            body["category_ids"] = AnyEncodable(categoryIds)
        }

        return try await client.post(path: "/api/rules/re-categorize", body: body)
    }
}