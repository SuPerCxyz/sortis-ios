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

    // 网页端标签色板
    static let chipNeutral = Color(hex: "A3A3A3")
    static let chipSuccess = Color(hex: "52C41A")
    static let chipWarning = Color(hex: "FA8C16")
    static let chipError = Color(hex: "FF4D4F")
    static let chipUncategorized = Color(hex: "FAAD14")
    static let chipEmail = Color(hex: "2F54EB")
    static let chipTelegram = Color(hex: "1677FF")
    static let chipWebhook = Color(hex: "13C2C2")
    static let chipRss = Color(hex: "D46B08")
    static let chipWebSocket = Color(hex: "722ED1")
    static let chipMutedBackground = Color(.sRGB, red: 140 / 255, green: 140 / 255, blue: 140 / 255, opacity: 0.14)
    static let chipMutedText = Color(hex: "8C8C8C")
    static let chipStatTotal = Color(hex: "69B1FF")
    static let chipStatRead = Color(hex: "BFBFBF")
    static let chipStatUnread = Color(hex: "FF4D4F")

    // 分类颜色预设
    static let categoryColors: [String] = [
        "#000000", "#1677FF", "#52C41A", "#FAAD14", "#FF4D4F",
        "#722ED1", "#13C2C2", "#EB2F96", "#FA8C16"
    ]

    static func generateVividCategoryColors(count: Int = 10) -> [String] {
        let normalizedCount = max(count, 1)
        let startHue = Double.random(in: 0...360)
        let hueStep = 360.0 / Double(normalizedCount)
        return (0..<normalizedCount).map { index in
            let jitter = Double.random(in: -8...8)
            let hue = (startHue + Double(index) * hueStep + jitter).truncatingRemainder(dividingBy: 360)
            let saturation = min(0.96, 0.76 + Double.random(in: 0...0.18))
            let brightness = min(0.98, 0.82 + Double.random(in: 0...0.14))
            let uiColor = UIColor(
                hue: CGFloat((hue + 360).truncatingRemainder(dividingBy: 360) / 360.0),
                saturation: CGFloat(saturation),
                brightness: CGFloat(brightness),
                alpha: 1
            )
            let red = Int((uiColor.cgColor.components?[0] ?? 0) * 255)
            let green = Int((uiColor.cgColor.components?[1] ?? 0) * 255)
            let blue = Int((uiColor.cgColor.components?[2] ?? 0) * 255)
            return String(format: "#%02X%02X%02X", red, green, blue)
        }
    }

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
