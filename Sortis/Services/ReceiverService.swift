//
//  ReceiverService.swift
//  Sortis
//
//  接收器服务
//

import Foundation

class ReceiverService {
    private let client = APIClient.shared

    // 获取接收器列表
    func getReceivers() async throws -> [Receiver] {
        return try await client.get(path: "/api/receivers")
    }

    // 获取接收器详情
    func getReceiver(receiverId: Int) async throws -> Receiver {
        return try await client.get(path: "/api/receivers/\(receiverId)")
    }

    // 创建接收器
    func createReceiver(name: String, type: String, config: [String: AnyEncodable]?, syncInterval: Int?) async throws -> Receiver {
        var body: [String: AnyEncodable] = [
            "name": AnyEncodable(name),
            "type": AnyEncodable(type)
        ]
        if let config = config {
            body["config"] = AnyEncodable(config)
        }
        if let syncInterval = syncInterval {
            body["sync_interval"] = AnyEncodable(syncInterval)
        }

        return try await client.post(path: "/api/receivers", body: body as! [String : AnyEncodable])
    }

    // 更新接收器
    func updateReceiver(receiverId: Int, name: String, config: [String: AnyEncodable]?, syncInterval: Int?) async throws -> Receiver {
        var body: [String: AnyEncodable] = [
            "name": AnyEncodable(name)
        ]
        if let config = config {
            body["config"] = AnyEncodable(config)
        }
        if let syncInterval = syncInterval {
            body["sync_interval"] = AnyEncodable(syncInterval)
        }

        return try await client.put(path: "/api/receivers/\(receiverId)", body: body as! [String : AnyEncodable])
    }

    // 同步接收器
    func syncReceiver(receiverId: Int) async throws -> Bool {
        let _: [String: String] = try await client.post(path: "/api/receivers/\(receiverId)/sync", body: Optional<Never>.none as Never?)
        return true
    }

    // 切换接收器状态
    func toggleReceiver(receiverId: Int) async throws -> Receiver {
        return try await client.post(path: "/api/receivers/\(receiverId)/toggle", body: Optional<Never>.none as Never?)
    }

    // 删除接收器
    func deleteReceiver(receiverId: Int) async throws -> Bool {
        return try await client.delete(path: "/api/receivers/\(receiverId)")
    }

    // 验证接收器配置
    func validateReceiver(type: String, config: [String: AnyEncodable]) async throws -> [String: Any] {
        let body: [String: AnyEncodable] = [
            "type": AnyEncodable(type),
            "config": AnyEncodable(config)
        ]
        return try await client.post(path: "/api/receivers/validate", body: body as! [String : AnyEncodable])
    }
}