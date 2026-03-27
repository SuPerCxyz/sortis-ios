//
//  AuthService.swift
//  Sortis
//
//  认证服务
//

import Foundation

class AuthService {
    private let client = APIClient.shared
    private let tokenManager = TokenManager.shared

    // 登录
    func login(username: String, password: String) async throws -> LoginResponse {
        let response: LoginResponse = try await client.postForm(
            path: "/api/auth/login",
            formData: [
                "username": username,
                "password": password
            ]
        )
        return response
    }

    // 保存登录状态
    func saveLogin(token: String, username: String, serverUrl: String) {
        tokenManager.saveToken(token)
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(serverUrl, forKey: "serverUrl")
    }

    // 退出登录
    func logout() {
        tokenManager.clearToken()
        UserDefaults.standard.removeObject(forKey: "username")
    }

    // 检查是否已登录
    func isLoggedIn() -> Bool {
        return tokenManager.hasToken()
    }

    // 获取当前用户名
    func getCurrentUsername() -> String? {
        return UserDefaults.standard.string(forKey: "username")
    }

    // 获取服务器地址
    func getServerUrl() -> String? {
        return UserDefaults.standard.string(forKey: "serverUrl")
    }

    // 设置服务器地址
    func setServerUrl(_ url: String) {
        UserDefaults.standard.set(url, forKey: "serverUrl")
    }

    // 修改密码
    func changePassword(current: String, new: String) async throws {
        let _: EmptyResponse = try await client.post(
            path: "/api/auth/change-password",
            body: [
                "current_password": current,
                "new_password": new
            ]
        )
    }

    // 删除账户
    func deleteAccount() async throws {
        let _: EmptyResponse = try await client.delete(path: "/api/auth/account")
        logout()
    }
}

// 空响应
struct EmptyResponse: Codable {}