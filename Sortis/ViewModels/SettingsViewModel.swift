//
//  SettingsViewModel.swift
//  Sortis
//
//  设置视图模型
//

import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var serverUrl: String = ""
    @Published var username: String = ""
    @Published var appVersion: String = ""
    @Published var buildNumber: String = ""

    @Published var showLogoutDialog: Bool = false
    @Published var showPasswordDialog: Bool = false
    @Published var showDeleteDialog: Bool = false

    private let authService = AuthService()

    init() {
        loadSettings()
    }

    func loadSettings() {
        serverUrl = authService.getServerUrl() ?? ""
        username = authService.getCurrentUsername() ?? ""

        // 获取应用版本
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildNumber = build
        }
    }

    func logout() {
        authService.logout()
    }

    func deleteAccount() {
        // TODO: 调用删除账户 API
        authService.logout()
    }
}