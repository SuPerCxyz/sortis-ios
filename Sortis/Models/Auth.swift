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