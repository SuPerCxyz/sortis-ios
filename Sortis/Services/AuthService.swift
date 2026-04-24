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

    // 注册
    func register(email: String, password: String) async throws -> UserResponse {
        try await client.post(
            path: "/api/auth/register",
            body: RegisterRequest(email: email, password: password)
        )
    }

    func getRegistrationStatus() async throws -> RegistrationStatusResponse {
        try await client.get(path: "/api/auth/registration-status")
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

    func updateCurrentEmail(_ email: String) {
        UserDefaults.standard.set(email, forKey: "username")
    }

    // 获取服务器地址
    func getServerUrl() -> String? {
        return UserDefaults.standard.string(forKey: "serverUrl")
    }

    // 设置服务器地址
    func setServerUrl(_ url: String) {
        UserDefaults.standard.set(url, forKey: "serverUrl")
    }

    func updateEmail(_ email: String) async throws -> UserResponse {
        let response: UserResponse = try await client.put(
            path: "/api/users/me",
            body: UserUpdateRequest(email: email)
        )
        updateCurrentEmail(response.email)
        return response
    }

    // 修改密码
    func changePassword(current: String, new: String) async throws {
        let _: UserResponse = try await client.put(
            path: "/api/users/me/change-password",
            body: ChangePasswordRequest(
                currentPassword: current,
                newPassword: new,
                confirmPassword: new
            )
        )
    }

    // 删除账户
    func deleteAccount() async throws {
        _ = try await client.delete(path: "/api/users/me")
        logout()
    }
}

// 空响应
struct EmptyResponse: Codable {}
