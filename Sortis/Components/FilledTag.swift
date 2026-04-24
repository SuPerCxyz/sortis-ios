import SwiftUI

struct FilledTag: View {
    let text: String
    let color: Color
    var textColor: Color = .white
    var font: Font = .caption
    var horizontalPadding: CGFloat = 8
    var verticalPadding: CGFloat = 3
    var style: FilledTagStyle = .roundedRect

    enum FilledTagStyle {
        case roundedRect
        case pill
    }

    var body: some View {
        Text(text)
            .font(font.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(color)
            .foregroundColor(textColor)
            .cornerRadius(style == .pill ? 999 : 6)
    }
}

func receiverTypeTagColor(_ type: String) -> Color {
    switch type {
    case "email": return .chipEmail
    case "telegram": return .chipTelegram
    case "http_token": return .chipWebhook
    case "rss": return .chipRss
    case "websocket": return .chipWebSocket
    default: return .chipNeutral
    }
}

func receiverStatusTagText(_ status: String) -> String {
    switch status {
    case "active": return "运行中"
    case "paused": return "已暂停"
    case "inactive": return "已停止"
    case "expired": return "已过期"
    case "error": return "错误"
    default: return status
    }
}

func receiverStatusTagColor(_ status: String) -> Color {
    switch status {
    case "active": return .chipSuccess
    case "paused": return .chipWarning
    case "inactive": return .chipNeutral
    case "expired", "error": return .chipError
    default: return .chipNeutral
    }
}

func tokenStatusTagColor(_ status: String) -> Color {
    switch status {
    case "active": return .chipSuccess
    case "expired": return .chipError
    default: return .chipWarning
    }
}

func tokenReceiverTagColor(_ index: Int) -> Color {
    let palette: [Color] = [.chipTelegram, .chipWebhook, .chipRss, .chipWebSocket]
    let safeIndex = ((index % palette.count) + palette.count) % palette.count
    return palette[safeIndex]
}

func categoryTagColor(_ colorHex: String?) -> Color {
    guard let colorHex, !colorHex.isEmpty else {
        return .chipTelegram
    }
    return Color(hex: colorHex)
}
