//
//  TokenService.swift
//  Sortis
//
//  Token 服务
//

import Foundation

class TokenService {
    private let client = APIClient.shared

    // 获取 Token 列表
    func getTokens() async throws -> [ApiToken] {
        return try await client.get(path: "/api/tokens")
    }

    // 获取 Token 详情
    func getToken(tokenId: Int) async throws -> ApiToken {
        return try await client.get(path: "/api/tokens/\(tokenId)")
    }

    // 创建 Token
    func createToken(name: String, receiverIds: [Int]?, expiresInDays: Int?, description: String? = nil) async throws -> TokenCreateResponse {
        var body: [String: AnyEncodable] = [
            "name": AnyEncodable(name)
        ]
        if let receiverIds = receiverIds {
            body["receiver_ids"] = AnyEncodable(receiverIds)
        }
        if let expiresInDays = expiresInDays {
            body["expires_in_days"] = AnyEncodable(expiresInDays)
        }
        if let description = description {
            body["description"] = AnyEncodable(description)
        }

        return try await client.post(path: "/api/tokens", body: body as! [String : AnyEncodable])
    }

    // 更新 Token
    func updateToken(tokenId: Int, name: String) async throws -> ApiToken {
        let body = TokenUpdateRequest(name: name)
        return try await client.put(path: "/api/tokens/\(tokenId)", body: body)
    }

    // 吊销 Token
    func revokeToken(tokenId: Int) async throws -> Bool {
        let _: [String: String] = try await client.post(path: "/api/tokens/\(tokenId)/revoke", body: Optional<Never>.none as Never?)
        return true
    }

    // 激活 Token
    func activateToken(tokenId: Int) async throws -> Bool {
        let _: [String: String] = try await client.post(path: "/api/tokens/\(tokenId)/activate", body: Optional<Never>.none as Never?)
        return true
    }

    // 删除 Token
    func deleteToken(tokenId: Int) async throws -> Bool {
        return try await client.delete(path: "/api/tokens/\(tokenId)")
    }

    // 绑定 Token 到接收器
    func bindTokenToReceiver(tokenId: Int, receiverId: Int?) async throws -> ApiToken {
        let body = BindTokenRequest(receiverId: receiverId, receiverIds: nil)
        return try await client.put(path: "/api/tokens/\(tokenId)/bind-receiver", body: body)
    }

    // 绑定 Token 到多个接收器
    func bindTokenToReceivers(tokenId: Int, receiverIds: [Int]) async throws -> ApiToken {
        let body = BindTokenRequest(receiverId: nil, receiverIds: receiverIds)
        return try await client.put(path: "/api/tokens/\(tokenId)/bind-receivers", body: body)
    }
}