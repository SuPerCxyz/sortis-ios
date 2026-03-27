//
//  StatsService.swift
//  Sortis
//
//  统计服务
//

import Foundation

class StatsService {
    private let client = APIClient.shared

    // 获取统计概览
    func getStatsOverview(days: Int? = nil) async throws -> StatsOverviewResponse {
        var queryItems: [URLQueryItem] = []
        if let days = days {
            queryItems.append(URLQueryItem(name: "days", value: String(days)))
        }
        return try await client.get(path: "/api/stats/overview", queryItems: queryItems.isEmpty ? nil : queryItems)
    }

    // 获取活跃度统计
    func getStatsActivity(days: Int = 30) async throws -> ActivityStatsResponse {
        let queryItems = [URLQueryItem(name: "days", value: String(days))]
        return try await client.get(path: "/api/stats/activity", queryItems: queryItems)
    }

    // 获取分类统计
    func getStatsCategories() async throws -> [CategoryStatsItem] {
        return try await client.get(path: "/api/stats/categories")
    }
}