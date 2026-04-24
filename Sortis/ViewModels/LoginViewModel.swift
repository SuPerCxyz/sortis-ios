//
//  LoginViewModel.swift
//  Sortis
//
//  登录视图模型
//

import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    private var registrationStatusTask: Task<Void, Never>?

    @Published var isRegisterMode: Bool = false
    @Published var isRegistrationEnabled: Bool = true
    @Published var serverUrl: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let authService = AuthService()

    init() {
        loadSavedState()
    }

    func loadSavedState() {
        if let savedServerUrl = authService.getServerUrl() {
            serverUrl = savedServerUrl
            refreshRegistrationAvailability(immediate: true)
        }
    }

    func login(onSuccess: @escaping () -> Void) async {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "请输入用户名和密码"
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let response = try await authService.login(username: username, password: password)
            authService.saveLogin(token: response.accessToken, username: response.username, serverUrl: serverUrl)
            onSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func register() async {
        guard isRegistrationEnabled else {
            errorMessage = "当前服务端已关闭注册"
            isRegisterMode = false
            return
        }
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "请输入邮箱和密码"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "两次输入的密码不一致"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "密码至少 6 位"
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            _ = try await authService.register(email: username, password: password)
            successMessage = "注册成功，请登录"
            isRegisterMode = false
            password = ""
            confirmPassword = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleMode() {
        if !isRegisterMode && !isRegistrationEnabled {
            errorMessage = "当前服务端已关闭注册"
            return
        }
        isRegisterMode.toggle()
        errorMessage = nil
        successMessage = nil
        password = ""
        confirmPassword = ""
    }

    func updateServerUrl(_ url: String) {
        serverUrl = url
        authService.setServerUrl(url)
        refreshRegistrationAvailability()
    }

    private func refreshRegistrationAvailability(immediate: Bool = false) {
        registrationStatusTask?.cancel()
        registrationStatusTask = Task { [weak self] in
            guard let self else { return }

            if !immediate {
                try? await Task.sleep(nanoseconds: 400_000_000)
            }

            let trimmedUrl = self.serverUrl.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedUrl.hasPrefix("http://") || trimmedUrl.hasPrefix("https://") else {
                self.isRegistrationEnabled = true
                return
            }

            do {
                let status = try await self.authService.getRegistrationStatus()
                self.isRegistrationEnabled = status.enabled
                if !status.enabled && self.isRegisterMode {
                    self.isRegisterMode = false
                    self.errorMessage = "当前服务端已关闭注册"
                }
            } catch {
                self.isRegistrationEnabled = true
            }
        }
    }
}
