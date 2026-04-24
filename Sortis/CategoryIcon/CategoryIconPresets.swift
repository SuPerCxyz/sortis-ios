//
//  CategoryIconPresets.swift
//  Sortis
//

import SwiftUI

struct CategoryIconOption: Hashable {
    let value: String
    let label: String
}

private struct CategoryIconGroup {
    let value: String
    let keys: [String]
    let label: String
    let symbolName: String
    let tint: Color
}

private func normalizeCategoryIconKey(_ icon: String?) -> String {
    icon?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
}

private let categoryIconGroups: [CategoryIconGroup] = [
    // 工作
    .init(value: "work", keys: ["folder", "work"], label: "工作", symbolName: "folder.fill", tint: Color(hex: "FAAD14")),
    .init(value: "business", keys: ["business", "bank"], label: "商务/银行", symbolName: "building.columns.fill", tint: .sortisInfo),
    .init(value: "api", keys: ["api"], label: "API", symbolName: "network", tint: .sortisInfo),
    .init(value: "meeting", keys: ["meeting", "calendar", "ticketing"], label: "会议/日历/票务", symbolName: "calendar", tint: .sortisInfo),
    .init(value: "project", keys: ["project", "task"], label: "项目/任务", symbolName: "pin.fill", tint: Color(hex: "722ED1")),
    .init(value: "resume", keys: ["resume"], label: "简历", symbolName: "person.text.rectangle.fill", tint: .sortisInfo),
    .init(value: "document", keys: ["document"], label: "文档", symbolName: "doc.text.fill", tint: .sortisInfo),
    .init(value: "contract", keys: ["contract", "legal"], label: "合同/法务", symbolName: "list.clipboard.fill", tint: Color(hex: "13C2C2")),
    .init(value: "invoice", keys: ["invoice", "tax"], label: "发票/税务", symbolName: "creditcard.fill", tint: Color(hex: "FA8C16")),
    .init(value: "approval", keys: ["approval", "checklist", "check"], label: "审批/清单/完成", symbolName: "checkmark.circle.fill", tint: .sortisSuccess),
    .init(value: "personal", keys: ["personal", "recruiting", "client"], label: "个人/招聘/客户", symbolName: "person.fill", tint: .sortisInfo),
    .init(value: "team", keys: ["team", "family", "friend", "parenting", "community"], label: "团队/家庭/朋友/育儿/社区", symbolName: "person.2.fill", tint: Color(hex: "EB2F96")),
    .init(value: "finance", keys: ["finance", "economy", "investment"], label: "财务/经济/投资", symbolName: "dollarsign.circle.fill", tint: .sortisSuccess),
    .init(value: "report", keys: ["report", "analytics"], label: "报表/数据分析", symbolName: "chart.bar.fill", tint: .sortisInfo),
    .init(value: "ticket", keys: ["ticket"], label: "工单", symbolName: "list.clipboard.fill", tint: Color(hex: "FA8C16")),
    .init(value: "deal", keys: ["deal"], label: "优惠", symbolName: "tag.fill", tint: Color(hex: "FA8C16")),

    // 技术
    .init(value: "security", keys: ["security"], label: "安全", symbolName: "checkmark.shield.fill", tint: .sortisError),
    .init(value: "technology", keys: ["technology", "tech", "code"], label: "技术/科技/编程", symbolName: "chevron.left.forwardslash.chevron.right", tint: .sortisInfo),
    .init(value: "ai", keys: ["ai"], label: "AI", symbolName: "sparkles", tint: Color(hex: "722ED1")),
    .init(value: "server", keys: ["server"], label: "服务器", symbolName: "server.rack", tint: Color(hex: "13C2C2")),
    .init(value: "database", keys: ["database"], label: "数据库", symbolName: "externaldrive.fill", tint: Color(hex: "13C2C2")),
    .init(value: "computer", keys: ["computer", "pc", "desktop"], label: "电脑/台式机", symbolName: "desktopcomputer", tint: .sortisInfo),
    .init(value: "laptop", keys: ["laptop", "notebook"], label: "笔记本", symbolName: "laptopcomputer", tint: .sortisInfo),
    .init(value: "monitor", keys: ["monitor", "display"], label: "显示器", symbolName: "display", tint: Color(hex: "13C2C2")),
    .init(value: "terminal", keys: ["terminal", "shell", "commandline"], label: "终端", symbolName: "terminal.fill", tint: .sortisInfo),
    .init(value: "network_device", keys: ["network", "network_device", "router", "switch"], label: "网络设备", symbolName: "point.3.connected.trianglepath.dotted", tint: Color(hex: "13C2C2")),
    .init(value: "chip", keys: ["chip", "cpu"], label: "芯片", symbolName: "cpu.fill", tint: Color(hex: "722ED1")),
    .init(value: "cloud_service", keys: ["cloud_service", "cloud_infra", "cloud_platform"], label: "云服务", symbolName: "cloud.fill", tint: Color(hex: "597EF7")),
    .init(value: "server_room", keys: ["server_room", "datacenter", "idc"], label: "机房", symbolName: "square.stack.3d.up.fill", tint: Color(hex: "13C2C2")),
    .init(value: "ops", keys: ["ops", "tools", "repair", "skill"], label: "运维/工具/维修/技能", symbolName: "wrench.and.screwdriver.fill", tint: .sortisInfo),
    .init(value: "monitoring", keys: ["monitoring"], label: "监控", symbolName: "eye.fill", tint: Color(hex: "FA8C16")),
    .init(value: "testing", keys: ["testing", "science", "research"], label: "测试/科学/研究", symbolName: "atom", tint: Color(hex: "13C2C2")),
    .init(value: "release", keys: ["release", "flag"], label: "发布/标记", symbolName: "flag.fill", tint: Color(hex: "722ED1")),

    // 出行
    .init(value: "travel", keys: ["travel"], label: "旅行", symbolName: "safari.fill", tint: .sortisInfo),
    .init(value: "flight", keys: ["flight"], label: "航班", symbolName: "airplane", tint: .sortisInfo),
    .init(value: "transport", keys: ["transport"], label: "交通", symbolName: "car.fill", tint: Color(hex: "13C2C2")),
    .init(value: "delivery", keys: ["delivery"], label: "快递", symbolName: "shippingbox.fill", tint: .sortisInfo),
    .init(value: "car", keys: ["car"], label: "汽车", symbolName: "car.fill", tint: .sortisInfo),
    .init(value: "bus", keys: ["bus"], label: "公交", symbolName: "bus.fill", tint: Color(hex: "13C2C2")),
    .init(value: "subway", keys: ["subway"], label: "地铁", symbolName: "tram.fill", tint: Color(hex: "13C2C2")),
    .init(value: "train", keys: ["train"], label: "火车", symbolName: "train.side.front.car", tint: .sortisInfo),

    // 生活
    .init(value: "home", keys: ["life", "home", "house", "hotel"], label: "生活/家/房屋/酒店", symbolName: "house.fill", tint: Color(hex: "FA8C16")),
    .init(value: "health", keys: ["health", "baby", "heart", "pet", "animal"], label: "健康/母婴/爱心/宠物/动物", symbolName: "heart.fill", tint: Color(hex: "EB2F96")),
    .init(value: "medical", keys: ["medical", "medicine"], label: "医疗/药品", symbolName: "cross.case.fill", tint: .sortisError),
    .init(value: "sport", keys: ["sport"], label: "运动", symbolName: "bolt.fill", tint: .sortisSuccess),
    .init(value: "sports", keys: ["sports"], label: "体育", symbolName: "trophy.fill", tint: .sortisSuccess),
    .init(value: "fitness", keys: ["fitness"], label: "健身", symbolName: "bolt.fill", tint: .sortisSuccess),
    .init(value: "food", keys: ["food", "takeaway", "recipe", "coffee", "cooking", "cafe"], label: "美食/外卖/菜谱/咖啡/烹饪/咖啡馆", symbolName: "fork.knife", tint: Color(hex: "FA8C16")),
    .init(value: "shopping", keys: ["shopping"], label: "购物", symbolName: "cart.fill", tint: Color(hex: "722ED1")),
    .init(value: "mall", keys: ["mall"], label: "商场", symbolName: "bag.fill", tint: Color(hex: "FA8C16")),
    .init(value: "ecommerce", keys: ["ecommerce"], label: "电商", symbolName: "storefront.fill", tint: .sortisInfo),
    .init(value: "shop", keys: ["shop"], label: "商店", symbolName: "storefront.fill", tint: .sortisInfo),
    .init(value: "decoration", keys: ["decoration", "furniture"], label: "装饰/家具", symbolName: "square.grid.2x2.fill", tint: Color(hex: "722ED1")),
    .init(value: "study", keys: ["study", "book", "education", "school", "university"], label: "学习/书籍/教育/学校/大学", symbolName: "book.fill", tint: .sortisInfo),
    .init(value: "reading", keys: ["learning", "reading", "course", "reading_plan"], label: "阅读/课程/阅读计划", symbolName: "text.book.closed.fill", tint: .sortisInfo),
    .init(value: "knowledge", keys: ["knowledge", "idea"], label: "知识/想法", symbolName: "lightbulb.fill", tint: Color(hex: "FAAD14")),
    .init(value: "sun", keys: ["sun"], label: "太阳", symbolName: "sun.max.fill", tint: Color(hex: "FAAD14")),
    .init(value: "phone", keys: ["phone", "mobile"], label: "手机", symbolName: "iphone", tint: Color(hex: "13C2C2")),
    .init(value: "tablet", keys: ["tablet", "ipad"], label: "平板", symbolName: "ipad", tint: Color(hex: "13C2C2")),
    .init(value: "printer", keys: ["printer"], label: "打印机", symbolName: "printer.fill", tint: .sortisInfo),
    .init(value: "camera_device", keys: ["camera_device"], label: "摄像设备", symbolName: "video.fill", tint: .sortisInfo),
    .init(value: "headphones", keys: ["headphones", "headset"], label: "耳机设备", symbolName: "headphones", tint: Color(hex: "722ED1")),
    .init(value: "office_device", keys: ["office_device", "office_hardware"], label: "办公设备", symbolName: "desktopcomputer", tint: .sortisInfo),
    .init(value: "email", keys: ["email"], label: "邮箱", symbolName: "envelope.fill", tint: .sortisInfo),
    .init(value: "clock", keys: ["clock"], label: "时间", symbolName: "clock.fill", tint: .sortisInfo),
    .init(value: "link", keys: ["link"], label: "链接", symbolName: "link", tint: .sortisInfo),
    .init(value: "warning", keys: ["warning"], label: "提醒", symbolName: "exclamationmark.triangle.fill", tint: Color(hex: "FA8C16")),
    .init(value: "cloud", keys: ["cloud", "weather"], label: "云朵/天气", symbolName: "cloud.fill", tint: Color(hex: "597EF7")),
    .init(value: "water", keys: ["water"], label: "水", symbolName: "drop.fill", tint: Color(hex: "13C2C2")),

    // 娱乐
    .init(value: "entertainment", keys: ["entertainment", "game", "play"], label: "娱乐/游戏", symbolName: "gamecontroller.fill", tint: Color(hex: "EB2F96")),
    .init(value: "console", keys: ["console", "game_console"], label: "游戏主机", symbolName: "gamecontroller.fill", tint: Color(hex: "722ED1")),
    .init(value: "movie", keys: ["movie", "film", "album"], label: "电影/影片/相册", symbolName: "film.fill", tint: Color(hex: "EB2F96")),
    .init(value: "music", keys: ["music", "music_note"], label: "音乐/音符", symbolName: "music.note", tint: Color(hex: "722ED1")),
    .init(value: "podcast", keys: ["podcast"], label: "播客", symbolName: "mic.fill", tint: Color(hex: "722ED1")),
    .init(value: "news", keys: ["news"], label: "新闻", symbolName: "megaphone.fill", tint: .sortisInfo),
    .init(value: "media", keys: ["media", "live"], label: "媒体/直播", symbolName: "play.tv.fill", tint: Color(hex: "722ED1")),
    .init(value: "art", keys: ["art"], label: "艺术", symbolName: "paintpalette.fill", tint: Color(hex: "EB2F96")),
    .init(value: "photo", keys: ["photo", "camera"], label: "摄影/相机", symbolName: "camera.fill", tint: .sortisInfo),
    .init(value: "nature", keys: ["plant", "tree", "flower"], label: "植物/树木/花朵", symbolName: "tree.fill", tint: .sortisSuccess),
    .init(value: "social", keys: ["social", "chat"], label: "社交/聊天", symbolName: "message.fill", tint: Color(hex: "13C2C2")),
    .init(value: "hobby", keys: ["hobby", "star"], label: "爱好/星标", symbolName: "star.fill", tint: Color(hex: "FAAD14")),
    .init(value: "fire", keys: ["fire"], label: "热门", symbolName: "flame.fill", tint: .sortisError),
    .init(value: "gift", keys: ["gift"], label: "礼物", symbolName: "gift.fill", tint: Color(hex: "EB2F96")),
    .init(value: "moon", keys: ["moon"], label: "月亮", symbolName: "moon.fill", tint: Color(hex: "597EF7")),

    // 接收器
    .init(value: "email_receiver", keys: ["email_receiver"], label: "邮箱接收器", symbolName: "envelope.fill", tint: .sortisInfo),
    .init(value: "webhook", keys: ["webhook"], label: "Webhook 接收器", symbolName: "network", tint: Color(hex: "FA8C16")),
    .init(value: "websocket", keys: ["websocket"], label: "WebSocket 接收器", symbolName: "wifi", tint: Color(hex: "13C2C2")),
    .init(value: "rss", keys: ["rss"], label: "RSS 接收器", symbolName: "text.book.closed.fill", tint: .sortisSuccess),
    .init(value: "telegram_receiver", keys: ["telegram_receiver"], label: "Telegram 接收器", symbolName: "paperplane.fill", tint: .sortisInfo),
    .init(value: "notification", keys: ["notification"], label: "通知", symbolName: "bell.fill", tint: Color(hex: "FA8C16")),
    .init(value: "location", keys: ["location"], label: "位置", symbolName: "location.viewfinder", tint: .sortisError),
]

private let categorySymbolMap = Dictionary(uniqueKeysWithValues: categoryIconGroups.flatMap { group in
    group.keys.map { key in (key, group.symbolName) }
})

private let categoryTintMap = Dictionary(uniqueKeysWithValues: categoryIconGroups.flatMap { group in
    group.keys.map { key in (key, group.tint) }
})

private let categoryLabelMap = Dictionary(uniqueKeysWithValues: categoryIconGroups.flatMap { group in
    group.keys.map { key in (key, group.label) }
})

private let categoryPickerValueMap = Dictionary(uniqueKeysWithValues: categoryIconGroups.flatMap { group in
    group.keys.map { key in (key, group.value) }
})

func getCategoryIconPickerValue(_ icon: String?) -> String? {
    let normalized = normalizeCategoryIconKey(icon)
    if normalized.hasPrefix("folder") {
        return "work"
    }
    return categoryPickerValueMap[normalized] ?? (normalized.isEmpty ? nil : normalized)
}

func categoryIconSymbolName(for icon: String?) -> String {
    let normalized = normalizeCategoryIconKey(icon)
    if normalized.hasPrefix("folder") {
        return categorySymbolMap["work"] ?? "folder.fill"
    }
    return categorySymbolMap[normalized] ?? "folder.fill"
}

func categoryIconTint(for icon: String?) -> Color {
    let normalized = normalizeCategoryIconKey(icon)
    if normalized.hasPrefix("folder") {
        return categoryTintMap["work"] ?? Color(hex: "FAAD14")
    }
    return categoryTintMap[normalized] ?? Color(hex: "FAAD14")
}

func getCategoryIconLabel(_ icon: String?) -> String {
    let normalized = normalizeCategoryIconKey(icon)
    if normalized.isEmpty {
        return "文件夹"
    }
    if normalized.hasPrefix("folder") {
        return categoryLabelMap["work"] ?? "工作"
    }
    return categoryLabelMap[normalized] ?? normalized
}

let categoryIconPresetOptions: [CategoryIconOption] =
    categoryIconGroups.map { CategoryIconOption(value: $0.value, label: $0.label) }
