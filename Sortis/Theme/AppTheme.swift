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
struct CategoryIconOption: Hashable {
    let value: String
    let label: String
}
private func normalizeCategoryIconKey(_ icon: String?) -> String {
    icon?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
}

private func categoryIconSymbolName(for icon: String?) -> String {
    let normalized = normalizeCategoryIconKey(icon)
    let key = normalized.hasPrefix("folder") ? "folder" : normalized
    switch key {
    case "folder", "work": return "folder.fill"
    case "business": return "briefcase.fill"
    case "api": return "network"
    case "meeting", "calendar", "ticketing": return "calendar"
    case "project", "task": return "pin.fill"
    case "resume", "document", "contract", "legal", "invoice", "report", "medicine", "note", "writing", "blog", "tax": return "doc.text.fill"
    case "approval", "checklist", "check": return "checkmark.circle.fill"
    case "recruiting", "client", "personal": return "person.fill"
    case "team", "family", "parenting", "community", "friend": return "person.2.fill"
    case "security", "deal", "ticket", "monitoring", "notification", "warning", "news", "live": return "bell.fill"
    case "server", "database": return "externaldrive.fill"
    case "ops", "tools", "repair", "skill": return "wrench.and.screwdriver.fill"
    case "analytics", "testing", "science", "research": return "atom"
    case "finance", "economy": return "dollarsign.circle.fill"
    case "bank": return "building.columns.fill"
    case "investment", "travel": return "safari.fill"
    case "flight": return "airplane"
    case "life", "home", "house", "hotel": return "house.fill"
    case "health", "medical", "heart", "baby", "pet", "animal": return "heart.fill"
    case "sport", "sports", "hobby", "star": return "star.fill"
    case "fitness": return "bolt.fill"
    case "food", "takeaway", "coffee", "cafe", "cooking": return "fork.knife"
    case "shopping": return "cart.fill"
    case "ecommerce", "shop": return "storefront.fill"
    case "delivery", "bus", "car": return "car.fill"
    case "subway", "train": return "tram.fill"
    case "decoration", "furniture", "entertainment", "game", "play": return "square.grid.2x2.fill"
    case "study", "education", "school", "university", "book", "recipe": return "book.fill"
    case "learning", "reading", "course", "reading_plan": return "text.book.closed.fill"
    case "knowledge", "idea", "sun": return "lightbulb.fill"
    case "technology", "tech", "code": return "chevron.left.forwardslash.chevron.right"
    case "ai": return "sparkles"
    case "movie", "film": return "film.fill"
    case "music", "music_note", "podcast", "media": return "music.note"
    case "art": return "paintpalette.fill"
    case "album": return "photo.on.rectangle.angled"
    case "photo", "camera": return "camera.fill"
    case "plant", "tree": return "tree.fill"
    case "flower": return "camera.macro"
    case "fire": return "flame.fill"
    case "gift": return "gift.fill"
    case "clock": return "clock.fill"
    case "location": return "location.fill"
    case "link": return "link"
    case "phone": return "iphone"
    case "email": return "envelope.fill"
    case "social", "chat": return "message.fill"
    case "flag": return "flag.fill"
    case "moon", "cloud", "weather": return "cloud.fill"
    case "utilities": return "building.columns.fill"
    case "water": return "drop.fill"
    default: return "folder.fill"
    }
}

private func categoryIconTint(for icon: String?) -> Color {
    let normalized = normalizeCategoryIconKey(icon)
    let key = normalized.hasPrefix("folder") ? "folder" : normalized
    switch key {
    case "folder", "work", "knowledge", "idea", "star", "sun": return Color(hex: "FAAD14")
    case "business", "api", "meeting", "resume", "document", "approval", "task", "recruiting", "client", "ops", "report", "tools", "bank", "personal", "travel", "delivery", "flight", "bus", "car", "repair", "study", "learning", "reading", "reading_plan", "book", "skill", "technology", "tech", "code", "photo", "camera", "news", "calendar", "clock", "link", "email": return .sortisInfo
    case "finance", "economy", "checklist", "check", "sport", "sports", "fitness", "plant", "tree": return .sortisSuccess
    case "security", "health", "medical", "fire", "location", "flag": return .sortisError
    case "project", "investment", "community", "friend", "shopping", "decoration", "game", "play", "ai", "music", "music_note", "podcast", "media", "release", "live": return Color(hex: "722ED1")
    case "contract", "legal", "server", "database", "tax", "analytics", "testing", "ticketing", "medicine", "subway", "train", "hotel", "utilities", "furniture", "course", "education", "school", "university", "science", "research", "phone", "social", "chat", "water": return Color(hex: "13C2C2")
    case "team", "family", "parenting", "baby", "heart", "entertainment", "movie", "film", "album", "art", "gift", "flower", "pet", "animal": return Color(hex: "EB2F96")
    case "invoice", "ticket", "monitoring", "life", "food", "takeaway", "recipe", "coffee", "cafe", "cooking", "deal", "home", "house", "shop", "notification", "warning": return Color(hex: "FA8C16")
    case "moon", "cloud", "weather": return Color(hex: "597EF7")
    default: return Color(hex: "FAAD14")
    }
}

func getCategoryIconLabel(_ icon: String?) -> String {
    let normalized = normalizeCategoryIconKey(icon)
    let key = normalized.hasPrefix("folder") ? "folder" : normalized
    switch key {
    case "": return "文件夹"
    case "folder": return "文件夹"
    case "work": return "工作"
    case "business": return "商务"
    case "api": return "API"
    case "meeting": return "会议"
    case "project": return "项目"
    case "resume": return "简历"
    case "document": return "文档"
    case "contract": return "合同"
    case "legal": return "法务"
    case "invoice": return "发票"
    case "approval": return "审批"
    case "task": return "任务"
    case "checklist": return "清单"
    case "recruiting": return "招聘"
    case "client": return "客户"
    case "team": return "团队"
    case "security": return "安全"
    case "server": return "服务器"
    case "ops": return "运维"
    case "report": return "报表"
    case "analytics": return "数据分析"
    case "ticket": return "工单"
    case "ticketing": return "票务"
    case "tools": return "工具"
    case "testing": return "测试"
    case "release": return "发布"
    case "monitoring": return "监控"
    case "finance": return "财务"
    case "economy": return "经济"
    case "bank": return "银行"
    case "database": return "数据库"
    case "tax": return "税务"
    case "investment": return "投资"
    case "personal": return "个人"
    case "life": return "生活"
    case "travel": return "旅行"
    case "delivery": return "快递"
    case "flight": return "航班"
    case "subway": return "地铁"
    case "bus": return "公交"
    case "family": return "家庭"
    case "friend": return "朋友"
    case "health": return "健康"
    case "medical": return "医疗"
    case "medicine": return "药品"
    case "baby": return "母婴"
    case "parenting": return "育儿"
    case "heart": return "爱心"
    case "sport": return "运动"
    case "sports": return "体育"
    case "fitness": return "健身"
    case "food": return "美食"
    case "takeaway": return "外卖"
    case "recipe": return "菜谱"
    case "coffee": return "咖啡"
    case "cafe": return "咖啡馆"
    case "cooking": return "烹饪"
    case "shopping": return "购物"
    case "ecommerce": return "电商"
    case "deal": return "优惠"
    case "hotel": return "酒店"
    case "car": return "汽车"
    case "train": return "火车"
    case "home": return "家"
    case "house": return "房屋"
    case "repair": return "维修"
    case "utilities": return "缴费"
    case "decoration": return "装饰"
    case "furniture": return "家具"
    case "study", "learning": return "学习"
    case "reading": return "阅读"
    case "reading_plan": return "阅读计划"
    case "book": return "书籍"
    case "note": return "笔记"
    case "writing": return "写作"
    case "course": return "课程"
    case "education": return "教育"
    case "school": return "学校"
    case "university": return "大学"
    case "knowledge": return "知识"
    case "skill": return "技能"
    case "technology": return "技术"
    case "tech": return "科技"
    case "code": return "编程"
    case "ai": return "AI"
    case "science": return "科学"
    case "research": return "研究"
    case "entertainment": return "娱乐"
    case "movie": return "电影"
    case "film": return "影片"
    case "music": return "音乐"
    case "music_note": return "音符"
    case "game": return "游戏"
    case "play": return "娱乐"
    case "hobby": return "爱好"
    case "art": return "艺术"
    case "album": return "相册"
    case "photo": return "摄影"
    case "camera": return "相机"
    case "pet": return "宠物"
    case "animal": return "动物"
    case "plant": return "植物"
    case "flower": return "花朵"
    case "news": return "新闻"
    case "media": return "媒体"
    case "blog": return "博客"
    case "podcast": return "播客"
    case "notification": return "通知"
    case "social": return "社交"
    case "community": return "社区"
    case "live": return "直播"
    case "idea": return "想法"
    case "star": return "星标"
    case "fire": return "热门"
    case "gift": return "礼物"
    case "calendar": return "日历"
    case "clock": return "时间"
    case "location": return "位置"
    case "link": return "链接"
    case "phone": return "手机"
    case "email": return "邮箱"
    case "chat": return "聊天"
    case "check": return "完成"
    case "warning": return "提醒"
    case "flag": return "标记"
    case "shop": return "商店"
    case "sun": return "太阳"
    case "moon": return "月亮"
    case "cloud": return "云朵"
    case "weather": return "天气"
    case "water": return "水"
    case "tree": return "树木"
    default: return key
    }
}
let categoryIconPresetOptions: [CategoryIconOption] = [
    "work", "document", "personal", "finance", "notification", "email", "chat", "shopping",
    "travel", "health", "task", "delivery", "weather", "medical", "legal", "server",
    "business", "meeting", "project", "contract", "invoice", "approval", "checklist",
    "recruiting", "client", "team", "security", "ops", "report", "analytics", "ticket",
    "ticketing", "tools", "testing", "release", "monitoring", "cloud", "flight", "subway",
    "bus", "medicine", "baby", "parenting", "repair", "utilities", "takeaway", "recipe",
    "album", "social", "community", "live", "reading_plan", "family", "fitness", "food",
    "bank", "tax", "investment", "tech", "code", "ai", "science", "education", "research",
    "news", "media", "blog", "podcast", "ecommerce", "deal", "hotel", "car", "train",
    "entertainment", "music", "game", "sports", "art", "photo", "api", "database", "idea",
    "star", "heart", "fire", "gift", "calendar", "clock", "location", "link", "phone",
    "check", "warning", "flag", "home", "shop", "cafe", "book", "music_note", "sun", "moon",
    "water", "tree", "flower"
].map { CategoryIconOption(value: $0, label: getCategoryIconLabel($0)) }
struct CategoryIconView: View {
    let icon: String?
    let iconUrl: String?
    let size: CGFloat
    let cornerRadius: CGFloat

    init(icon: String?, iconUrl: String?, size: CGFloat = 18, cornerRadius: CGFloat = 4) {
        self.icon = icon
        self.iconUrl = iconUrl
        self.size = size
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        if let iconUrl, let url = URL(string: iconUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                default:
                    fallbackIcon
                }
            }
        } else {
            fallbackIcon
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: categoryIconSymbolName(for: icon))
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(categoryIconTint(for: icon))
            .frame(width: size, height: size)
    }
}
