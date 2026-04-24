//
//  MessageCard.swift
//  Sortis
//
//  消息卡片组件
//

import SwiftUI

struct MessageCard: View {
    let message: Message
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // 第一行：接收器名称 | 分类 | 时间
                HStack {
                    Text(message.sourceName ?? "未知来源")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    // 分类标签
                    if let category = message.categories?.first {
                        FilledTag(
                            text: category.name,
                            color: categoryTagColor(category.color)
                        )
                    } else {
                        FilledTag(
                            text: "未分类",
                            color: .chipUncategorized
                        )
                    }

                    Spacer()

                    Text(message.receivedAt.formatDateTime())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // 第二行：状态图标 | 标题 | 星标
                HStack(spacing: 8) {
                    Image(systemName: message.isRead ? "envelope.open" : "envelope.fill")
                        .foregroundColor(message.isRead ? .messageRead : .messageUnread)
                        .font(.system(size: 16))

                    Text(message.title ?? "(无标题)")
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 星标图标 - 未星标描边，星标时金色填充
                    Image(systemName: message.isStarred ? "star.fill" : "star")
                        .foregroundColor(message.isStarred ? .messageStarred : .secondary)
                        .font(.system(size: 16))
                }

                // 第三行：内容预览
                if let content = message.content, !content.isEmpty {
                    Text(content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 消息详情弹窗
struct MessageDetailSheet: View {
    let message: Message
    let onToggleRead: () -> Void
    let onToggleStar: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 来源信息
                    HStack {
                        Text(message.sourceName ?? "未知来源")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(message.receivedAt.formatDateTime())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // 标题
                    Text(message.title ?? "(无标题)")
                        .font(.title3)
                        .fontWeight(.semibold)

                    // 分类标签
                    if let categories = message.categories, !categories.isEmpty {
                        HStack {
                            ForEach(categories, id: \.id) { cat in
                                FilledTag(
                                    text: cat.name,
                                    color: categoryTagColor(cat.color)
                                )
                            }
                        }
                    } else {
                        FilledTag(
                            text: "未分类",
                            color: .chipUncategorized
                        )
                    }

                    Divider()

                    // 内容
                    if let content = message.content, !content.isEmpty {
                        Text(content)
                            .font(.body)
                    } else {
                        Text("(无内容)")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("消息详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: onToggleRead) {
                            Image(systemName: message.isRead ? "envelope.badge" : "envelope.open")
                        }
                        Button(action: onToggleStar) {
                            // 星标图标 - 未星标描边，星标时金色填充
                            Image(systemName: message.isStarred ? "star.fill" : "star")
                                .foregroundColor(message.isStarred ? .messageStarred : .primary)
                        }
                    }
                }
            }
        }
    }
}

// 消息操作弹窗
struct MessageActionSheet: View {
    let message: Message
    let categories: [FlatCategory]
    let onToggleRead: () -> Void
    let onToggleStar: () -> Void
    let onMove: (Int) -> Void
    let onDelete: (Bool) -> Void
    let onDismiss: () -> Void

    @State private var showMoveSheet = false
    @State private var showDeleteOptions = false

    private var isEmailMessage: Bool {
        message.receiver?.type == "email"
    }

    var body: some View {
        VStack(spacing: 0) {
            // 标题
            Text(message.title ?? "(无标题)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))

            Divider()

            // 操作按钮
            Button(action: {
                onToggleRead()
                onDismiss()
            }) {
                Text(message.isRead ? "标记为未读" : "标记为已读")
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            Divider()

            Button(action: {
                onToggleStar()
                onDismiss()
            }) {
                Text(message.isStarred ? "取消星标" : "添加星标")
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            Divider()

            Button(action: {
                showMoveSheet = true
            }) {
                Text("移动到分类")
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            Divider()

            Button(action: {
                if isEmailMessage {
                    showDeleteOptions = true
                } else {
                    onDelete(false)
                    onDismiss()
                }
            }) {
                Text("删除")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            Divider()

            Button(action: onDismiss) {
                Text("取消")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .sheet(isPresented: $showMoveSheet) {
            MoveToCategorySheet(categories: categories) { categoryId in
                onMove(categoryId)
                showMoveSheet = false
                onDismiss()
            }
        }
        .confirmationDialog(
            "确认删除邮件信息",
            isPresented: $showDeleteOptions,
            titleVisibility: .visible
        ) {
            Button("仅删除本地", role: .destructive) {
                onDelete(false)
                onDismiss()
            }
            Button("删除远端内容", role: .destructive) {
                onDelete(true)
                onDismiss()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("仅删除本地会保留远端邮件，并阻止这条邮件下次再同步回来；删除远端内容会同时从邮箱服务器删除原邮件。")
        }
    }
}

// 移动到分类弹窗
struct MoveToCategorySheet: View {
    let categories: [FlatCategory]
    let onSelect: (Int) -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(categories) { flatCategory in
                Button(action: {
                    onSelect(flatCategory.id)
                    dismiss()
                }) {
                    HStack {
                        if let color = flatCategory.category.color {
                            Rectangle()
                                .fill(Color(hex: color))
                                .frame(width: 14, height: 14)
                                .cornerRadius(3)
                        }
                        Text(flatCategory.category.name)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, CGFloat(flatCategory.indent * 12))
                }
            }
            .navigationTitle("移动到分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}
