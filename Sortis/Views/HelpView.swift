//
//  HelpView.swift
//  Sortis
//
//  帮助中心视图
//

import SwiftUI

struct HelpView: View {
    @State private var selectedTopic: HelpTopic?

    let helpTopics: [HelpTopic] = [
        HelpTopic(
            id: 1,
            title: "Webhook 接收器使用指南",
            description: "了解如何通过 Webhook 发送消息到 Sortis，支持多种编程语言和认证方式",
            icon: "📡",
            content: """
            ## Webhook 接收器

            - 通过 HTTP POST 被动接收外部系统推送的消息。
            - 常用于监控告警、CI/CD 和业务系统通知。
            - 请求体使用 JSON，认证支持 Bearer Token 或 X-API-Token。
        """
        ),
        HelpTopic(
            id: 2,
            title: "WebSocket 接收器使用指南",
            description: "学习如何配置 WebSocket 长连接，实现实时消息推送",
            icon: "🔌",
            content: """
            ## WebSocket 接收器

            - 通过长连接实时推送消息，适合高实时性场景。
            - 支持连接时认证，也支持连接后发送认证消息。
            - 建议客户端定期发送心跳并实现自动重连。
        """
        ),
        HelpTopic(
            id: 3,
            title: "Telegram 接收器使用指南",
            description: "学习如何配置 Telegram Bot 接收消息，实现 Telegram 通知推送",
            icon: "✈️",
            content: """
            ## Telegram 接收器

            - 先在 @BotFather 创建 Bot 并获取 Token。
            - 在 Sortis 中创建 Telegram 接收器后，将 Token 填入配置。
            - 使用前先向 Bot 发送 `/start`，再等待系统同步消息。
        """
        ),
        HelpTopic(
            id: 4,
            title: "邮件接收器使用指南",
            description: "配置邮箱接收器，通过 IMAP 协议自动拉取和分类邮件通知",
            icon: "📧",
            content: """
            ## 邮件接收器

            - 使用 IMAP 协议主动拉取邮箱中的邮件消息。
            - 删除邮件时可选择仅删除本地，或同时删除远端内容。
            - 标记已读或未读会同步到服务端，再同步到 IMAP 邮箱服务器。
        """
        ),
        HelpTopic(
            id: 5,
            title: "RSS 接收器使用指南",
            description: "订阅 RSS/Atom Feed 源，自动获取网站更新和通知",
            icon: "📰",
            content: """
            ## RSS 接收器

            - 通过 RSS 或 Atom 订阅源主动拉取内容更新。
            - 适合博客、新闻站点和论坛动态聚合。
            - 系统会基于订阅项唯一标识去重，避免重复创建消息。
        """
        ),
        HelpTopic(
            id: 6,
            title: "信息视图使用指南",
            description: "统一查看消息，支持条件搜索、状态筛选、时间过滤和详情阅读",
            icon: "👁️",
            content: """
            ## 信息视图

            - 统一查看所有接收器同步过来的消息。
            - 支持“搜索条件 + 关键词”查询，可按标题、内容、来源、接收器、分类检索。
            - 支持按状态、时间范围、分类筛选，并可直接进入消息详情。
        """
        ),
        HelpTopic(
            id: 7,
            title: "仪表盘使用指南",
            description: "查看总览统计、阅读进度、接收器状态、趋势图和分类统计",
            icon: "📊",
            content: """
            ## 仪表盘

            - 顶部卡片展示总信息数、星标、接收器、分类。
            - 阅读进度与接收器状态用于快速判断处理压力和运行健康度。
            - 支持查看近 30 天趋势、分类统计和接收器详情。
        """
        ),
        HelpTopic(
            id: 8,
            title: "消息管理使用指南",
            description: "支持条件搜索、批量已读/未读、星标、移动分类与删除",
            icon: "📝",
            content: """
            ## 消息管理

            - 支持“搜索条件 + 关键词”组合查询和多维筛选。
            - 提供批量标记已读/未读、批量星标、批量删除和批量修改分类。
            - 适合处理积压消息和执行日常清理。
        """
        ),
        HelpTopic(
            id: 9,
            title: "接收器管理使用指南",
            description: "创建、配置和管理接收器，掌握接收器启停和故障排查",
            icon: "🔧",
            content: """
            ## 接收器管理

            - 统一管理 Webhook、WebSocket、Telegram、邮件和 RSS 接收器。
            - 支持新建、编辑、启用、暂停、删除和手动同步。
            - 出现异常时可结合状态与错误信息进行排查。
        """
        ),
        HelpTopic(
            id: 10,
            title: "分类管理使用指南",
            description: "维护分类层级、颜色和图标，并查看分类下的信息统计",
            icon: "📁",
            content: """
            ## 分类管理

            - 支持创建、编辑、删除分类，并可设置父分类形成层级结构。
            - 可配置分类名称、颜色、预设图标或自定义图标。
            - 删除分类后，原有消息会回到未分类状态。
        """
        ),
        HelpTopic(
            id: 11,
            title: "分类规则配置指南",
            description: "学习如何配置分类规则，自动将消息归类到不同的分类",
            icon: "⚙️",
            content: """
            ## 分类规则

            - 规则会在消息到达时自动匹配并归类。
            - 支持标题、正文、来源和原始 JSON 等条件。
            - Webhook 与 WebSocket 的原始 JSON 可直接用于条件匹配和模板渲染。
        """
        ),
        HelpTopic(
            id: 12,
            title: "Token 管理使用指南",
            description: "了解如何创建、管理和吊销 API Token，保障接口安全",
            icon: "🔑",
            content: """
            ## Token 管理

            - Token 用于 API 认证和接收器调用鉴权。
            - 支持创建、复制、配置、暂停/恢复和删除。
            - 创建时可关联多个接收器并配置过期时间。
            - 建议为不同调用方使用独立 Token，并定期轮换。
        """
        ),
        HelpTopic(
            id: 13,
            title: "设置页面使用指南",
            description: "管理邮箱、密码、登录状态与账户删除等安全操作",
            icon: "⚙️",
            content: """
            ## 设置页面

            - 账户信息支持更新邮箱。
            - 修改密码成功后会触发重新登录。
            - 支持退出登录和删除账户（删除后数据不可恢复）。
            """
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // 搜索框（占位）
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    Text("搜索帮助主题")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .padding(.horizontal)

                // 帮助主题列表
                LazyVStack(spacing: 8) {
                    ForEach(helpTopics) { topic in
                        HelpTopicRow(topic: topic)
                            .onTapGesture {
                                selectedTopic = topic
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(item: $selectedTopic) { topic in
            HelpDetailSheet(topic: topic)
        }
    }
}

// 帮助主题模型
struct HelpTopic: Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let icon: String
    let content: String
}

// 帮助主题行
struct HelpTopicRow: View {
    let topic: HelpTopic

    var body: some View {
        HStack(spacing: 12) {
            Text(topic.icon)
                .font(.system(size: 20))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(topic.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
    }
}

// 帮助详情弹窗
struct HelpDetailSheet: View {
    let topic: HelpTopic

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 标题
                    HStack {
                        Text(topic.icon)
                            .font(.system(size: 28))

                        Text(topic.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Divider()

                    // 内容
                    Text(markdownToAttributedString(topic.content))
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func markdownToAttributedString(_ markdown: String) -> AttributedString {
        do {
            return try AttributedString(markdown: markdown, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            return AttributedString(markdown)
        }
    }
}
