//
//  AppTheme.swift
//  Sortis
//
//  主题配置
//

import SwiftUI

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

// 分类图标映射
let categoryIcons: [String: String] = [
    "work": "📁",
    "business": "💼",
    "meeting": "📅",
    "project": "📌",
    "document": "📄",
    "personal": "👤",
    "family": "👨‍👩‍👧‍👦",
    "health": "❤️",
    "fitness": "🏃",
    "food": "🍔",
    "finance": "💰",
    "bank": "🏦",
    "tax": "📊",
    "investment": "📈",
    "tech": "💻",
    "code": "⌨️",
    "ai": "🤖",
    "science": "🔬",
    "education": "📚",
    "research": "📖",
    "news": "📰",
    "media": "📺",
    "blog": "📝",
    "podcast": "🎙️",
    "shopping": "🛒",
    "ecommerce": "📦",
    "deal": "🏷️",
    "travel": "✈️",
    "hotel": "🏨",
    "car": "🚗",
    "train": "🚆",
    "entertainment": "🎬",
    "music": "🎵",
    "game": "🎮",
    "sports": "⚽",
    "art": "🎨",
    "photo": "📷",
    "idea": "💡",
    "star": "⭐",
    "heart": "💖",
    "fire": "🔥",
    "gift": "🎁",
    "calendar": "📆",
    "clock": "⏰",
    "location": "📍",
    "link": "🔗",
    "phone": "📱",
    "email": "📧",
    "chat": "💬",
    "check": "✅",
    "warning": "⚠️",
    "flag": "🚩",
    "home": "🏠",
    "shop": "🏪",
    "cafe": "☕",
    "book": "📘",
    "music_note": "🎶",
    "sun": "☀️",
    "moon": "🌙",
    "cloud": "☁️",
    "water": "💧",
    "tree": "🌲",
    "flower": "🌸"
]

func getIconEmoji(_ icon: String?) -> String {
    guard let icon = icon else { return "📁" }
    return categoryIcons[icon] ?? "📁"
}