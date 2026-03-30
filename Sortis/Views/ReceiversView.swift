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
                                boundTokenName: viewModel.boundToken(for: receiver)?.name,
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
                tokens: viewModel.tokens,
                serverUrl: viewModel.serverUrl,
                onSave: { name, type, syncInterval, config, selectedTokenId, tokenName, tokenDescription, tokenExpiresInDays in
                    viewModel.createReceiver(
                        name: name,
                        type: type,
                        syncInterval: syncInterval,
                        config: config.mapValues { AnyEncodable($0) },
                        selectedTokenId: selectedTokenId,
                        tokenName: tokenName,
                        tokenDescription: tokenDescription,
                        tokenExpiresInDays: tokenExpiresInDays
                    )
                },
                onDismiss: { viewModel.setCreateOpen(false) }
            )
        }
        .sheet(item: $viewModel.editReceiver) { receiver in
            ReceiverEditDialog(
                receiver: receiver,
                tokens: viewModel.tokens,
                serverUrl: viewModel.serverUrl,
                onSave: { name, _, syncInterval, config, selectedTokenId, _, _, _ in
                    viewModel.updateReceiver(
                        receiverId: receiver.id,
                        name: name,
                        syncInterval: syncInterval,
                        config: config.mapValues { AnyEncodable($0) },
                        selectedTokenId: selectedTokenId
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

struct ReceiverCard: View {
    let receiver: Receiver
    let boundTokenName: String?
    let onToggle: () -> Void
    let onSync: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: receiverTypeIcon(receiver.type))
                    .font(.system(size: 16))
                    .foregroundColor(.sortisPrimary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(receiver.name)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)

                    Text(receiverTypeName(receiver.type))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(receiverStatusText(receiver.status))
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(receiverStatusColor(receiver.status).opacity(0.16))
                    .foregroundColor(receiverStatusColor(receiver.status))
                    .cornerRadius(4)
            }

            Text(boundTokenName ?? "未绑定 Token")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)

            if let configPreview = buildReceiverConfigSummary(config: receiver.configDictionary) {
                Text(configPreview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            HStack {
                Text(receiverActivityText(receiver))
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                if receiver.type != "http_token" && receiver.type != "websocket" {
                    Text("每 \(receiver.syncInterval ?? 5) 分钟")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("被动接收")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    if receiver.type != "http_token" && receiver.type != "websocket" {
                        Button(action: onSync) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                                .foregroundColor(.sortisPrimary)
                        }
                    }

                    Toggle("", isOn: Binding(
                        get: { receiver.status == "active" || receiver.isEnabled },
                        set: { _ in onToggle() }
                    ))
                    .labelsHidden()
                    .scaleEffect(0.7)

                    Menu {
                        Button(action: onEdit) {
                            Label("配置", systemImage: "pencil")
                        }
                        if receiver.type != "http_token" && receiver.type != "websocket" {
                            Button(action: onSync) {
                                Label("手动同步", systemImage: "arrow.clockwise")
                            }
                        }
                        Divider()
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

            if let errorMessage = receiver.errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.sortisError)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ReceiverEditDialog: View {
    let receiver: Receiver?
    let tokens: [ApiToken]
    let serverUrl: String?
    let onSave: (String, String, Int, [String: Any], Int?, String?, String?, Int?) -> Void
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var type: String = "email"
    @State private var syncInterval: Int = 5

    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var imapHost: String = ""
    @State private var imapPort: String = "993"
    @State private var smtpHost: String = ""
    @State private var smtpPort: String = "465"
    @State private var folder: String = "INBOX"
    @State private var botToken: String = ""
    @State private var feedUrl: String = ""

    @State private var selectedTokenId: Int?
    @State private var tokenName: String = ""
    @State private var tokenDescription: String = ""
    @State private var tokenExpiresInDays: Int?

    @Environment(\.dismiss) var dismiss

    private let typeOptions = [
        ("email", "邮件 (IMAP)"),
        ("telegram", "Telegram Bot"),
        ("http_token", "HTTP Webhook"),
        ("rss", "RSS 订阅"),
        ("websocket", "WebSocket")
    ]

    private let syncOptions = [1, 5, 10, 15, 30, 60]
    private let tokenExpiryOptions: [Int?] = [nil, 1, 7, 30, 90, 365]

    private var activeTokens: [ApiToken] {
        tokens.filter(\.isActive)
    }

    private var currentBoundToken: ApiToken? {
        if let selectedTokenId {
            return activeTokens.first(where: { $0.id == selectedTokenId })
        }
        guard let receiver else { return nil }
        return activeTokens.first {
            ($0.receiverIds ?? []).contains(receiver.id) || $0.receiverId == receiver.id
        }
    }

    private var webhookUrl: String {
        guard
            let receiver,
            let publicId = receiver.publicId,
            let serverUrl
        else { return "" }
        return "\(serverUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/api/webhook/\(publicId)"
    }

    private var webSocketUrl: String {
        guard
            let receiver,
            let publicId = receiver.publicId,
            let serverUrl
        else { return "" }

        let trimmedBase = serverUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let wsBase: String
        if trimmedBase.hasPrefix("https://") {
            wsBase = "wss://\(String(trimmedBase.dropFirst("https://".count)))"
        } else if trimmedBase.hasPrefix("http://") {
            wsBase = "ws://\(String(trimmedBase.dropFirst("http://".count)))"
        } else {
            wsBase = "ws://\(trimmedBase)"
        }

        let tokenPart = currentBoundToken?.tokenPreview ?? currentBoundToken?.plainToken
        if let tokenPart, !tokenPart.isEmpty {
            return "\(wsBase)/ws/receiver/\(publicId)?token=\(tokenPart)"
        }
        return "\(wsBase)/ws/receiver/\(publicId)"
    }

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

                if type != "http_token" && type != "websocket" {
                    Section(header: Text("同步频率")) {
                        Picker("每隔多久同步", selection: $syncInterval) {
                            ForEach(syncOptions, id: \.self) { value in
                                Text("\(value) 分钟").tag(value)
                            }
                        }
                    }
                }

                receiverConfigSection

                if receiver != nil && (type == "http_token" || type == "websocket") {
                    Section(header: Text("绑定 Token")) {
                        Picker("选择 Token", selection: $selectedTokenId) {
                            Text("未绑定").tag(nil as Int?)
                            ForEach(activeTokens) { token in
                                Text(token.name).tag(token.id as Int?)
                            }
                        }

                        LabeledContent("当前 Token") {
                            Text(currentBoundToken?.name ?? "未绑定")
                                .foregroundColor(.secondary)
                        }
                    }
                } else if type == "http_token" {
                    Section(header: Text("创建 Token")) {
                        TextField("Token 名称", text: $tokenName)
                        TextField("Token 描述", text: $tokenDescription)

                        Picker("过期时间", selection: $tokenExpiresInDays) {
                            ForEach(tokenExpiryOptions, id: \.self) { days in
                                Text(days.map { "\($0) 天" } ?? "永不过期").tag(days as Int?)
                            }
                        }

                        Text("创建接收器后会自动创建并绑定 Token。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(receiver == nil ? "新建接收器" : "接收器配置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        onDismiss()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        onSave(
                            name.trimmingCharacters(in: .whitespacesAndNewlines),
                            type,
                            syncInterval,
                            buildConfig(),
                            selectedTokenId,
                            tokenName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tokenName.trimmingCharacters(in: .whitespacesAndNewlines),
                            tokenDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tokenDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                            tokenExpiresInDays
                        )
                        dismiss()
                    }
                    .disabled(!isConfigValid())
                }
            }
        }
        .onAppear {
            loadInitialValues()
        }
    }

    @ViewBuilder
    private var receiverConfigSection: some View {
        Section(header: Text("配置")) {
            switch type {
            case "email":
                TextField("邮箱地址", text: $emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("授权码/密码", text: $password)
                TextField("IMAP 服务器", text: $imapHost)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("IMAP 端口", text: $imapPort)
                    .keyboardType(.numberPad)
                TextField("SMTP 服务器", text: $smtpHost)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("SMTP 端口", text: $smtpPort)
                    .keyboardType(.numberPad)
                TextField("收件箱文件夹", text: $folder)
            case "telegram":
                SecureField("Bot Token", text: $botToken)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            case "rss":
                TextField("RSS 订阅地址", text: $feedUrl)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            case "http_token":
                Text(receiver == nil ? "创建后会显示真实的 Webhook 地址。" : "当前接收器支持直接复制 Webhook 地址和 Token 绑定。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if receiver != nil {
                    TextField("Webhook URL", text: .constant(webhookUrl))
                        .disabled(true)
                }
            case "websocket":
                Text(receiver == nil ? "创建完成后请到 Token 管理页创建 Token，再回来绑定。" : "当前接收器支持直接复制 WebSocket 地址和 Token 绑定。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if receiver != nil {
                    TextField("WebSocket URL", text: .constant(webSocketUrl))
                        .disabled(true)
                }
            default:
                EmptyView()
            }
        }
    }

    private func loadInitialValues() {
        guard let receiver else { return }

        name = receiver.name
        type = receiver.type
        syncInterval = receiver.syncInterval ?? 5
        selectedTokenId = activeTokens.first(where: { ($0.receiverIds ?? []).contains(receiver.id) || $0.receiverId == receiver.id })?.id

        let config = receiver.configDictionary
        emailAddress = config["email_address"] as? String ?? ""
        imapHost = config["imap_host"] as? String ?? ""
        imapPort = String(config["imap_port"] as? Int ?? 993)
        smtpHost = config["smtp_host"] as? String ?? ""
        smtpPort = String(config["smtp_port"] as? Int ?? 465)
        folder = config["folder"] as? String ?? "INBOX"
        feedUrl = config["feed_url"] as? String ?? ""
    }

    private func buildConfig() -> [String: Any] {
        var config: [String: Any] = [:]

        switch type {
        case "email":
            if !emailAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                config["email_address"] = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if !password.isEmpty {
                config["password"] = password
            }
            if !imapHost.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                config["imap_host"] = imapHost.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            config["imap_port"] = Int(imapPort) ?? 993
            if !smtpHost.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                config["smtp_host"] = smtpHost.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            config["smtp_port"] = Int(smtpPort) ?? 465
            if !folder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                config["folder"] = folder.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        case "telegram":
            if !botToken.isEmpty {
                config["bot_token"] = botToken
            }
        case "rss":
            if !feedUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                config["feed_url"] = feedUrl.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        default:
            break
        }

        return config
    }

    private func isConfigValid() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }

        switch type {
        case "email":
            return !emailAddress.isEmpty && emailAddress.contains("@")
        case "telegram":
            return !botToken.isEmpty
        case "rss":
            let trimmedUrl = feedUrl.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedUrl.hasPrefix("http://") || trimmedUrl.hasPrefix("https://")
        case "http_token", "websocket":
            return true
        default:
            return false
        }
    }
}

private extension Receiver {
    var configDictionary: [String: Any] {
        config?.value as? [String: Any] ?? [:]
    }
}

private func receiverTypeIcon(_ type: String) -> String {
    switch type {
    case "http_token": return "link"
    case "websocket": return "antenna.radiowaves.left.and.right"
    case "email": return "envelope"
    case "telegram": return "paperplane"
    case "rss": return "dot.radiowaves.left.and.right"
    default: return "questionmark.circle"
    }
}

private func receiverTypeName(_ type: String) -> String {
    switch type {
    case "http_token": return "Webhook"
    case "websocket": return "WebSocket"
    case "email": return "邮箱"
    case "telegram": return "Telegram"
    case "rss": return "RSS"
    default: return type
    }
}

private func receiverStatusText(_ status: String) -> String {
    switch status {
    case "active": return "运行中"
    case "paused", "inactive": return "已暂停"
    case "error": return "错误"
    default: return status
    }
}

private func receiverStatusColor(_ status: String) -> Color {
    switch status {
    case "active": return .sortisSuccess
    case "paused", "inactive": return .sortisWarning
    case "error": return .sortisError
    default: return .secondary
    }
}

private func receiverActivityText(_ receiver: Receiver) -> String {
    let activityTime = (receiver.type == "http_token" || receiver.type == "websocket") ? receiver.lastReceivedAt : receiver.lastSyncAt
    let prefix = (receiver.type == "http_token" || receiver.type == "websocket") ? "最近接收" : "最近同步"
    return "\(prefix): \(activityTime?.formatDateTime() ?? "暂无")"
}

private func buildReceiverConfigSummary(config: [String: Any]) -> String? {
    if let emailAddress = config["email_address"] as? String, !emailAddress.isEmpty {
        return "邮箱: \(emailAddress)"
    }
    if let feedUrl = config["feed_url"] as? String, !feedUrl.isEmpty {
        return "RSS: \(feedUrl)"
    }
    if config["bot_token"] != nil {
        return "Bot Token: ***"
    }
    if let imapHost = config["imap_host"] as? String, !imapHost.isEmpty {
        return "IMAP: \(imapHost):\(config["imap_port"] ?? 993)"
    }
    if config.isEmpty {
        return nil
    }
    return config.map { "\($0.key)=\($0.value)" }
        .sorted()
        .joined(separator: ", ")
}
