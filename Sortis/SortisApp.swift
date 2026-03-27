//
//  SortisApp.swift
//  Sortis
//
//  应用入口
//

import SwiftUI

@main
struct SortisApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                MainView()
                    .environmentObject(appState)
            } else {
                LoginView()
                    .environmentObject(appState)
            }
        }
    }
}

// 应用状态
class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var serverUrl: String = ""
    @Published var username: String = ""

    private let tokenManager = TokenManager.shared

    init() {
        loadSavedState()
    }

    func loadSavedState() {
        serverUrl = UserDefaults.standard.string(forKey: "serverUrl") ?? ""
        username = UserDefaults.standard.string(forKey: "username") ?? ""
        if let token = tokenManager.getToken(), !token.isEmpty {
            isLoggedIn = true
        }
    }

    func login(token: String, username: String, serverUrl: String) {
        tokenManager.saveToken(token)
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(serverUrl, forKey: "serverUrl")
        self.username = username
        self.serverUrl = serverUrl
        self.isLoggedIn = true
    }

    func logout() {
        tokenManager.clearToken()
        UserDefaults.standard.removeObject(forKey: "username")
        username = ""
        isLoggedIn = false
    }
}