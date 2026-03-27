//
//  ReceiversView.swift
//  Sortis
//
//  接收器管理视图
//

import SwiftUI

struct ReceiversView: View {
    @StateObject private var viewModel = ReceiversViewModel()

    @State private var showDeleteConfirm = false

    var body: some View {
        VStack {
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.receivers.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("暂无接收器")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.receivers) { receiver in
                            ReceiverCard(
                                receiver: receiver,
                                onToggle: { viewModel.toggleReceiver(receiverId: receiver.id) },
                                onSync: { viewModel.syncReceiver(receiverId: receiver.id) },
                                onEdit: { viewModel.setEditReceiver(receiver) },
                                onDelete: {
                                    viewModel.setActionReceiver(receiver)
                                    showDeleteConfirm = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .refreshable {
                    viewModel.refresh()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.setCreateOpen(true) }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isCreateOpen) {
            ReceiverEditDialog(
                receiver: nil,
                onSave: { name, type, config in
                    viewModel.createReceiver(
                        name: name,
                        type: type,
                        config: config.mapValues { AnyEncodable($0) },
                        syncInterval: nil
                    )
                },
                onDismiss: { viewModel.setCreateOpen(false) }
            )
        }
        .sheet(item: $viewModel.editReceiver) { receiver in
            ReceiverEditDialog(
                receiver: receiver,
                onSave: { name, type, config in
                    viewModel.updateReceiver(
                        receiverId: receiver.id,
                        name: name,
                        config: config.mapValues { AnyEncodable($0) },
                        syncInterval: nil
                    )
                },
                onDismiss: { viewModel.setEditReceiver(nil) }
            )
        }
        .alert("确认删除", isPresented: $showDeleteConfirm) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let receiver = viewModel.actionReceiver {
                    viewModel.deleteReceiver(receiverId: receiver.id)
                }
            }
        } message: {
            Text("确定要删除此接收器吗？")
        }
    }
}

// 接收器卡片
struct ReceiverCard: View {
    let receiver: Receiver
    let onToggle: () -> Void
    let onSync: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // 类型图标
                Image(systemName: getTypeIcon(receiver.type))
                    .font(.system(size: 16))
                    .foregroundColor(.sortisPrimary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(receiver.name)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)

                    Text(getTypeName(receiver.type))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 状态
                Text(receiver.isEnabled ? "启用" : "停用")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(receiver.isEnabled ? Color.sortisSuccess.opacity(0.2) : Color.secondary.opacity(0.2))
                    .foregroundColor(receiver.isEnabled ? .sortisSuccess : .secondary)
                    .cornerRadius(4)
            }

            // 配置预览
            if let configPreview = getConfigPreview(receiver) {
                Text(configPreview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            // 底部信息
            HStack {
                Text("消息: \(receiver.messageCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // 操作按钮
                HStack(spacing: 12) {
                    Button(action: onSync) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                            .foregroundColor(.sortisPrimary)
                    }

                    Toggle("", isOn: Binding(
                        get: { receiver.isEnabled },
                        set: { _ in onToggle() }
                    ))
                    .labelsHidden()
                    .scaleEffect(0.7)

                    Menu {
                        Button(action: onEdit) {
                            Label("编辑", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: onDelete) {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private func getTypeIcon(_ type: String) -> String {
        switch type {
        case "webhook": return "link"
        case "websocket": return "antenna.radiowaves.left.and.right"
        case "email": return "envelope"
        case "telegram": return "message"
        case "rss": return "newspaper"
        default: return "questionmark.circle"
        }
    }

    private func getTypeName(_ type: String) -> String {
        switch type {
        case "webhook": return "Webhook"
        case "websocket": return "WebSocket"
        case "email": return "Email"
        case "telegram": return "Telegram"
        case "rss": return "RSS"
        default: return type
        }
    }

    private func getConfigPreview(_ receiver: Receiver) -> String? {
        guard let config = receiver.config?.value as? [String: Any] else { return nil }
        switch receiver.type {
        case "webhook":
            if let path = config["path"] as? String {
                return "路径: \(path)"
            }
        case "email":
            if let email = config["email"] as? String {
                return "邮箱: \(email)"
            }
        case "telegram":
            if let token = config["token"] as? String {
                return "Token: \(String(token.prefix(10)))..."
            }
        case "rss":
            if let url = config["url"] as? String {
                return "URL: \(url)"
            }
        default:
            break
        }
        return nil
    }
}

// 接收器编辑对话框
struct ReceiverEditDialog: View {
    let receiver: Receiver?
    let onSave: (String, String, [String: Any]) -> Void
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var type: String = "webhook"
    @State private var webhookPath: String = ""
    @State private var email: String = ""
    @State private var telegramToken: String = ""
    @State private var rssUrl: String = ""

    @Environment(\.dismiss) var dismiss

    let typeOptions = [
        ("webhook", "Webhook"),
        ("websocket", "WebSocket"),
        ("email", "Email"),
        ("telegram", "Telegram"),
        ("rss", "RSS")
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("接收器名称", text: $name)

                    Picker("类型", selection: $type) {
                        ForEach(typeOptions, id: \.0) { value, label in
                            Text(label).tag(value)
                        }
                    }
                    .disabled(receiver != nil)
                }

                Section(header: Text("配置")) {
                    switch type {
                    case "webhook":
                        VStack(alignment: .leading, spacing: 4) {
                            Text("路径")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("/webhook/your-path", text: $webhookPath)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }

                    case "email":
                        VStack(alignment: .leading, spacing: 4) {
                            Text("邮箱地址")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("email@example.com", text: $email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }

                    case "telegram":
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bot Token")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("输入 Bot Token", text: $telegramToken)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }

                    case "rss":
                        VStack(alignment: .leading, spacing: 4) {
                            Text("RSS URL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("https://example.com/feed", text: $rssUrl)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }

                    case "websocket":
                        Text("WebSocket 接收器通过服务端配置连接")
                            .font(.caption)
                            .foregroundColor(.secondary)

                    default:
                        EmptyView()
                    }
                }
            }
            .navigationTitle(receiver == nil ? "新建接收器" : "编辑接收器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let config = buildConfig()
                        onSave(name, type, config)
                        dismiss()
                    }
                    .disabled(name.isEmpty || !isConfigValid())
                }
            }
        }
        .onAppear {
            if let receiver = receiver {
                name = receiver.name
                type = receiver.type
                loadConfig(receiver.config)
            }
        }
    }

    private func buildConfig() -> [String: Any] {
        switch type {
        case "webhook":
            return ["path": webhookPath]
        case "email":
            return ["email": email]
        case "telegram":
            return ["token": telegramToken]
        case "rss":
            return ["url": rssUrl]
        default:
            return [:]
        }
    }

    private func loadConfig(_ config: AnyCodable?) {
        guard let config = config?.value as? [String: Any] else { return }
        switch type {
        case "webhook":
            webhookPath = config["path"] as? String ?? ""
        case "email":
            email = config["email"] as? String ?? ""
        case "telegram":
            telegramToken = config["token"] as? String ?? ""
        case "rss":
            rssUrl = config["url"] as? String ?? ""
        default:
            break
        }
    }

    private func isConfigValid() -> Bool {
        switch type {
        case "webhook":
            return !webhookPath.isEmpty
        case "email":
            return !email.isEmpty && email.contains("@")
        case "telegram":
            return !telegramToken.isEmpty
        case "rss":
            return !rssUrl.isEmpty && rssUrl.hasPrefix("http")
        case "websocket":
            return true
        default:
            return false
        }
    }
}