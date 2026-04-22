//
//  AppTheme.swift
//  Sortis
//
//  主题配置
//
import SwiftUI

enum AppAssets {
    static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return .main
        #endif
    }
}

struct AppTheme {
    // 抽屉菜单宽度
    static let drawerWidth: CGFloat = 220

    // 卡片圆角
    static let cardCornerRadius: CGFloat = 10

    // 小圆角
    static let smallCornerRadius: CGFloat = 6

    // 默认分页大小
    static let defaultPageSize: Int = 20

    // 大分页大小（用于全量加载）
    static let largePageSize: Int = 10000

    // 间距
    struct Spacing {
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }

    // 字体大小
    struct FontSize {
        static let caption: CGFloat = 11
        static let body2: CGFloat = 12
        static let body1: CGFloat = 14
        static let subtitle: CGFloat = 15
        static let title3: CGFloat = 16
        static let title2: CGFloat = 18
        static let title1: CGFloat = 20
        static let largeTitle: CGFloat = 24
    }

    // 图标大小
    struct IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 18
        static let large: CGFloat = 20
        static let extraLarge: CGFloat = 24
    }
}
