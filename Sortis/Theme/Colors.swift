//
//  Colors.swift
//  Sortis
//
//  颜色配置 - 与 Android 应用保持一致
//

import SwiftUI

extension Color {
    // 主色调
    static let sortisPrimary = Color(hex: "667EEA")
    static let sortisPrimaryDark = Color(hex: "764BA2")

    // 状态颜色
    static let sortisSuccess = Color(hex: "52C41A")
    static let sortisWarning = Color(hex: "FAAD14")
    static let sortisError = Color(hex: "FF4D4F")
    static let sortisInfo = Color(hex: "1677FF")

    // 消息状态颜色
    static let messageRead = Color(hex: "1890FF")
    static let messageUnread = Color(hex: "73D13D")
    static let messageStarred = Color(hex: "FAAD14")

    // 分类颜色预设
    static let categoryColors: [String] = [
        "#1677FF", "#52C41A", "#FAAD14", "#FF4D4F",
        "#722ED1", "#13C2C2", "#EB2F96", "#FA8C16"
    ]

    // 渐变色
    static let sortisGradient = LinearGradient(
        colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
        startPoint: .leading,
        endPoint: .trailing
    )

    // 从十六进制字符串创建颜色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // 转换为十六进制字符串
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}