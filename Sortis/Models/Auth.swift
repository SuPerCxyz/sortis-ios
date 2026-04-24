//
//  Auth.swift
//  Sortis
//
//  认证相关模型
//

import Foundation

// 登录请求
struct LoginRequest: Encodable {
    let username: String
    let password: String
}

// 登录响应
struct LoginResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let username: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case username
    }
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
}

struct UserUpdateRequest: Encodable {
    let email: String
}

struct UserResponse: Decodable {
    let id: Int
    let email: String
    let isActive: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

struct RegistrationStatusResponse: Decodable {
    let enabled: Bool
}

struct ChangePasswordRequest: Encodable {
    let currentPassword: String
    let newPassword: String
    let confirmPassword: String

    enum CodingKeys: String, CodingKey {
        case currentPassword = "current_password"
        case newPassword = "new_password"
        case confirmPassword = "confirm_password"
    }
}
