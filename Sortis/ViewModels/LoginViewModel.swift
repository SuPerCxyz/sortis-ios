//
//  LoginViewModel.swift
//  Sortis
//
//  登录视图模型
//

import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    @Published var serverUrl: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authService = AuthService()

    init() {
        loadSavedState()
    }

    func loadSavedState() {
        if let savedServerUrl = authService.getServerUrl() {
            serverUrl = savedServerUrl
        }
    }

    func login(onSuccess: @escaping () -> Void) async {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "请输入用户名和密码"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await authService.login(username: username, password: password)
            authService.saveLogin(token: response.accessToken, username: response.username, serverUrl: serverUrl)
            onSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateServerUrl(_ url: String) {
        serverUrl = url
        authService.setServerUrl(url)
    }
}