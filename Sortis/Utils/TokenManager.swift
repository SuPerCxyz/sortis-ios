//
//  TokenManager.swift
//  Sortis
//
//  Token 管理器
//

import Foundation

class TokenManager {
    static let shared = TokenManager()

    private let tokenKey = "auth_token"
    private let keychain = KeychainManager.shared

    private init() {}

    func saveToken(_ token: String) {
        _ = keychain.save(key: tokenKey, value: token)
    }

    func getToken() -> String? {
        return keychain.get(key: tokenKey)
    }

    func clearToken() {
        _ = keychain.delete(key: tokenKey)
    }

    func hasToken() -> Bool {
        guard let token = getToken() else { return false }
        return !token.isEmpty
    }
}