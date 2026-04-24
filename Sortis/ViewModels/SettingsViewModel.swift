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
    @Published var draftEmail: String = ""
    @Published var appVersion: String = ""
    @Published var buildNumber: String = ""

    @Published var showLogoutDialog: Bool = false
    @Published var showPasswordDialog: Bool = false
    @Published var showEmailDialog: Bool = false
    @Published var showDeleteDialog: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var feedbackMessage: String?

    private let authService = AuthService()

    init() {
        loadSettings()
    }

    func loadSettings() {
        serverUrl = authService.getServerUrl() ?? ""
        username = authService.getCurrentUsername() ?? ""
        draftEmail = username

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
        Task {
            isSubmitting = true
            do {
                try await authService.deleteAccount()
                feedbackMessage = "账户已删除"
            } catch {
                feedbackMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }

    func updateEmail() {
        let trimmedEmail = draftEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            feedbackMessage = "请输入邮箱地址"
            return
        }

        Task {
            isSubmitting = true
            do {
                let response = try await authService.updateEmail(trimmedEmail)
                username = response.email
                draftEmail = response.email
                showEmailDialog = false
                feedbackMessage = "邮箱更新成功"
            } catch {
                feedbackMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}
