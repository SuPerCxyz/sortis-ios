//
//  MainViewModel.swift
//  Sortis
//
//  主视图模型
//

import Foundation

@MainActor
class MainViewModel: ObservableObject {
    @Published var currentRoute: String = "view"
    @Published var isDrawerOpen: Bool = false

    func navigateTo(_ route: String) {
        currentRoute = route
        isDrawerOpen = false
    }

    func toggleDrawer() {
        isDrawerOpen.toggle()
    }

    func closeDrawer() {
        isDrawerOpen = false
    }
}

// 菜单项
enum MenuItem: String, CaseIterable, Identifiable {
    case view = "view"
    case dashboard = "dashboard"
    case messages = "messages"
    case categories = "categories"
    case rules = "rules"
    case receivers = "receivers"
    case tokens = "tokens"
    case settings = "settings"
    case help = "help"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .view: return "信息视图"
        case .dashboard: return "仪表盘"
        case .messages: return "信息管理"
        case .categories: return "分类管理"
        case .rules: return "分类规则"
        case .receivers: return "接收器管理"
        case .tokens: return "Token 管理"
        case .settings: return "设置"
        case .help: return "帮助中心"
        }
    }

    var iconKind: SortisSidebarIconKind {
        switch self {
        case .view: return .view
        case .dashboard: return .dashboard
        case .messages: return .messages
        case .categories: return .categories
        case .rules: return .rules
        case .receivers: return .receivers
        case .tokens: return .tokens
        case .settings: return .settings
        case .help: return .help
        }
    }
}

// 主菜单项
let mainMenuItems: [MenuItem] = [.view]

// 后台管理菜单项
let adminMenuItems: [MenuItem] = [.dashboard, .messages, .categories, .rules, .receivers, .tokens, .help, .settings]
