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
            title: "快速开始",
            icon: "rocket",
            content: """
            ## 欢迎使用 Sortis！

            Sortis 是一个消息聚合管理平台，帮助您集中管理来自多个渠道的消息。

            ### 主要功能
            - **消息聚合**: 支持 Webhook、Email、Telegram、RSS 等多种接收方式
            - **智能分类**: 通过规则自动将消息归类
            - **消息管理**: 标记已读、星标、移动、删除等操作

            ### 快速上手
            1. 创建接收器获取推送地址
            2. 配置分类规则自动归类消息
            3. 在消息列表中查看和管理消息
            """
        ),
        HelpTopic(
            id: 2,
            title: "接收器配置",
            icon: "antenna.radiowaves.left.and.right",
            content: """
            ## 接收器类型

            ### Webhook
            通用 HTTP 接收器，支持任何 HTTP POST 请求。
            - 创建后获得专属 URL
            - 支持 JSON 格式消息体

            ### Email
            邮件接收器，可通过 SMTP 接收邮件。
            - 绑定邮箱地址
            - 支持附件解析

            ### Telegram
            Telegram Bot 接收器。
            - 创建 Telegram Bot
            - 获取 Bot Token 并配置
            - 消息自动推送到 Sortis

            ### RSS
            RSS/Atom 订阅源接收器。
            - 输入 RSS 源地址
            - 定时自动抓取更新
            """
        ),
        HelpTopic(
            id: 3,
            title: "分类规则",
            icon: "slider.horizontal.3",
            content: """
            ## 分类规则

            分类规则用于自动将消息归类到指定分类。

            ### 匹配条件
            - **标题**: 匹配消息标题
            - **内容**: 匹配消息正文内容
            - **来源名称**: 匹配接收器名称
            - **来源类型**: 匹配接收器类型

            ### 匹配方式
            - **包含**: 消息包含指定文本
            - **等于**: 消息完全等于指定文本
            - **开头为**: 消息以指定文本开头
            - **结尾为**: 消息以指定文本结尾
            - **正则匹配**: 使用正则表达式匹配

            ### 使用示例
            标题包含"警告"的消息自动归类到"告警"分类。
            """
        ),
        HelpTopic(
            id: 4,
            title: "消息操作",
            icon: "envelope",
            content: """
            ## 消息管理

            ### 消息状态
            - **已读/未读**: 标记消息阅读状态
            - **星标**: 标记重要消息

            ### 操作方式
            - **点击消息**: 查看详情
            - **长按消息**: 打开操作菜单
            - **操作菜单**:
              - 标记已读/未读
              - 添加/取消星标
              - 移动到其他分类
              - 删除消息

            ### 筛选方式
            - **Tab 切换**: 全部/未读/星标/未分类
            - **时间范围**: 按时间筛选消息
            - **分页浏览**: 支持分页加载
            """
        ),
        HelpTopic(
            id: 5,
            title: "API Token",
            icon: "key",
            content: """
            ## API Token

            API Token 用于通过 API 访问 Sortis。

            ### 创建 Token
            1. 进入 Token 管理页面
            2. 点击右上角"+"按钮
            3. 输入名称和有效期
            4. 保存生成的 Token

            ### 注意事项
            - Token 只显示一次，请妥善保管
            - 可随时停用或删除 Token
            - 建议为不同用途创建不同 Token

            ### API 使用
            在请求头添加:
            ```
            Authorization: Bearer <your-token>
            ```
            """
        ),
        HelpTopic(
            id: 6,
            title: "常见问题",
            icon: "questionmark.circle",
            content: """
            ## 常见问题

            ### Q: 收不到消息？
            1. 检查接收器是否启用
            2. 检查接收器配置是否正确
            3. 检查网络连接

            ### Q: 消息分类不正确？
            1. 检查规则是否启用
            2. 检查规则条件是否正确
            3. 点击"重新分类"按钮

            ### Q: 如何备份数据？
            目前需要通过后端 API 导出数据。

            ### Q: 忘记密码怎么办？
            联系管理员重置密码。

            ### 更多帮助
            访问官方网站: https://sortis.app
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
    let icon: String
    let content: String
}

// 帮助主题行
struct HelpTopicRow: View {
    let topic: HelpTopic

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: topic.icon)
                .font(.system(size: 20))
                .foregroundColor(.sortisPrimary)
                .frame(width: 32)

            Text(topic.title)
                .font(.system(size: 14))
                .lineLimit(1)

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
                        Image(systemName: topic.icon)
                            .font(.system(size: 28))
                            .foregroundColor(.sortisPrimary)

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