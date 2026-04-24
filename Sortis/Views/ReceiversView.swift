//
//  ReceiversView.swift
//  Sortis
//
//  接收器管理视图
//

import SwiftUI

struct ReceiversView: View {
    @StateObject private var viewModel = ReceiversViewModel()

    @State private var selectedReceiver: Receiver?
    @State private var deleteCandidate: Receiver?

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Menu {
                    ForEach(receiverSearchFieldOptions) { option in
                        Button(action: {
                            viewModel.setSearch(query: viewModel.searchQuery, field: option.value)
                        }) {
                            if viewModel.searchField == option.value {
                                Label(option.label, systemImage: "checkmark")
                            } else {
                                Text(option.label)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(searchFieldLabel(for: viewModel.searchField, options: receiverSearchFieldOptions))
                            .font(.caption)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
                SortisSearchIcon(size: 16, color: .secondary)
                TextField("", text: $viewModel.searchQuery)
                    .sortisCenteredPlaceholder("搜索接收器", isEmpty: viewModel.searchQuery.isEmpty)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit {
                        viewModel.setSearch(query: viewModel.searchQuery, field: viewModel.searchField)
                    }
                if !viewModel.searchQuery.isEmpty {
                    Button("搜索") {
                        viewModel.setSearch(query: viewModel.searchQuery, field: viewModel.searchField)
                    }
                    .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)

            HStack {
                PaginationControl(
                    currentPage: viewModel.currentPage,
                    totalPages: viewModel.totalPages,
                    onPageChange: { viewModel.changePage($0) }
                )
                Spacer()
                Text("共 \(viewModel.total) 条")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

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
                List {
                        ForEach(viewModel.receivers) { receiver in
                            ReceiverEntityCard(
                                receiver: receiver,
                                boundTokenName: viewModel.boundToken(for: receiver)?.name
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedReceiver = receiver
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    viewModel.setEditReceiver(receiver)
                                } label: {
                                    Label("配置", systemImage: "pencil")
                                }
                                .tint(.sortisInfo)

                                Button {
                                    viewModel.toggleReceiver(receiverId: receiver.id)
                                } label: {
                                    Label(receiver.status == "active" ? "停用" : "启用", systemImage: receiver.status == "active" ? "pause.fill" : "play.fill")
                                }
                                .tint(.sortisWarning)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if receiver.type != "http_token" && receiver.type != "websocket" {
                                    Button {
                                        viewModel.syncReceiver(receiverId: receiver.id)
                                    } label: {
                                        Label("同步", systemImage: "arrow.clockwise")
                                    }
                                    .tint(.sortisSuccess)
                                }
                                Button(role: .destructive) {
                                    deleteCandidate = receiver
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.refresh()
                }
            }
        }
        .navigationDestination(item: $selectedReceiver) { receiver in
            ReceiverEntityDetailView(
                receiver: receiver,
                boundTokenName: viewModel.boundToken(for: receiver)?.name
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.setCreateOpen(true) }) {
                    SortisCreateIcon(size: 18)
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
        .alert("确认删除", isPresented: Binding(
            get: { deleteCandidate != nil },
            set: { if !$0 { deleteCandidate = nil } }
        )) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let receiver = deleteCandidate {
                    viewModel.deleteReceiver(receiverId: receiver.id)
                }
                deleteCandidate = nil
            }
        } message: {
            Text("确定要删除此接收器吗？")
        }
    }
}

struct ReceiverCard: View {
    let receiver: Receiver
    let boundTokenName: String?

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

                FilledTag(
                    text: receiverStatusTagText(receiver.status),
                    color: receiverStatusTagColor(receiver.status)
                )
            }

            if let boundTokenName, !boundTokenName.isEmpty {
                FilledTag(
                    text: boundTokenName,
                    color: receiverTypeTagColor(receiver.type)
                )
            } else {
                FilledTag(
                    text: "未绑定",
                    color: .chipMutedBackground,
                    textColor: .chipMutedText
                )
            }

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

struct ReceiverDetailView: View {
    let receiver: Receiver
    let boundTokenName: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(receiver.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    FilledTag(text: receiverTypeName(receiver.type), color: receiverTypeTagColor(receiver.type))
                    FilledTag(text: receiverStatusTagText(receiver.status), color: receiverStatusTagColor(receiver.status))
                }

                receiverDetailRow("名称", receiver.name)
                receiverDetailRow("类型", receiverTypeName(receiver.type))
                receiverDetailRow("状态", receiverStatusText(receiver.status))
                receiverDetailRow("接收器 ID", receiver.publicId ?? "未生成")
                receiverDetailRow("Token", boundTokenName ?? "未绑定")
                receiverDetailRow("频率", receiver.type == "http_token" || receiver.type == "websocket" ? "被动接收" : "每 \(receiver.syncInterval ?? 5) 分钟")
                receiverDetailRow(receiver.type == "http_token" || receiver.type == "websocket" ? "最近接收" : "最近同步", ((receiver.type == "http_token" || receiver.type == "websocket") ? receiver.lastReceivedAt : receiver.lastSyncAt)?.formatDateTime() ?? "暂无")
                receiverDetailRow("创建时间", (receiver.createdAt ?? "").formatDateTime())
                receiverDetailRow("更新时间", (receiver.updatedAt ?? "").formatDateTime())

                if let summary = buildReceiverConfigSummary(config: receiver.configDictionary) {
                    receiverDetailSection("配置摘要", summary)
                }

                if let errorMessage = receiver.errorMessage, !errorMessage.isEmpty {
                    receiverDetailSection("错误信息", errorMessage)
                }
            }
            .padding(16)
        }
        .navigationTitle("接收器管理")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func receiverDetailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value.isEmpty ? "-" : value)
                .font(.body)
        }
    }

    private func receiverDetailSection(_ title: String, _ content: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(content)
                .font(.body)
        }
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
    @State private var fetchAllFolders: Bool = false
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
        ("http_token", "Webhook"),
        ("rss", "RSS 订阅"),
        ("websocket", "WebSocket")
    ]

    private let syncOptions = [1, 5, 10, 15, 30, 60]
    private let tokenExpiryOptions: [Int?] = [nil, 1, 7, 30, 90, 365]
    private var tokenNameBinding: Binding<String> {
        Binding(
            get: { tokenName },
            set: { newValue in
                if selectedTokenId != nil, !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    selectedTokenId = nil
                }
                tokenName = newValue
            }
        )
    }
    private var tokenDescriptionBinding: Binding<String> {
        Binding(
            get: { tokenDescription },
            set: { newValue in
                if selectedTokenId != nil, !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    selectedTokenId = nil
                }
                tokenDescription = newValue
            }
        )
    }
    private var tokenExpiresInDaysBinding: Binding<Int?> {
        Binding(
            get: { tokenExpiresInDays },
            set: { newValue in
                if selectedTokenId != nil, newValue != nil {
                    selectedTokenId = nil
                }
                tokenExpiresInDays = newValue
            }
        )
    }

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
                    TextField("", text: $name)
                        .sortisCenteredPlaceholder("接收器名称", isEmpty: name.isEmpty)

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
                } else if type == "http_token" || type == "websocket" {
                    Section(header: Text("选择或创建 Token")) {
                        Picker("选择已有 Token", selection: $selectedTokenId) {
                            Text("未选择").tag(nil as Int?)
                            ForEach(activeTokens) { token in
                                Text(token.name).tag(token.id as Int?)
                            }
                        }
                        .disabled(!tokenName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .onChange(of: selectedTokenId) { _, newValue in
                            guard newValue != nil else { return }
                            tokenName = ""
                            tokenDescription = ""
                            tokenExpiresInDays = nil
                        }

                        TextField("", text: tokenNameBinding)
                            .sortisCenteredPlaceholder("Token 名称", isEmpty: tokenName.isEmpty)
                            .disabled(selectedTokenId != nil)
                        TextField("", text: tokenDescriptionBinding)
                            .sortisCenteredPlaceholder("Token 描述", isEmpty: tokenDescription.isEmpty)
                            .disabled(selectedTokenId != nil)

                        Picker("过期时间", selection: tokenExpiresInDaysBinding) {
                            ForEach(tokenExpiryOptions, id: \.self) { days in
                                Text(days.map { "\($0) 天" } ?? "永不过期").tag(days as Int?)
                            }
                        }
                        .disabled(selectedTokenId != nil)

                        Text("可直接选择已有 Token，或创建一个新 Token 并在保存后自动绑定。两种方式二选一。")
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
                TextField("", text: $emailAddress)
                    .sortisCenteredPlaceholder("邮箱地址", isEmpty: emailAddress.isEmpty)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("", text: $password)
                    .sortisCenteredPlaceholder("授权码/密码", isEmpty: password.isEmpty)
                TextField("", text: $imapHost)
                    .sortisCenteredPlaceholder("IMAP 服务器", isEmpty: imapHost.isEmpty)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("", text: $imapPort)
                    .sortisCenteredPlaceholder("IMAP 端口", isEmpty: imapPort.isEmpty)
                    .keyboardType(.numberPad)
                TextField("", text: $smtpHost)
                    .sortisCenteredPlaceholder("SMTP 服务器", isEmpty: smtpHost.isEmpty)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("", text: $smtpPort)
                    .sortisCenteredPlaceholder("SMTP 端口", isEmpty: smtpPort.isEmpty)
                    .keyboardType(.numberPad)
                Toggle("接收所有文件夹邮件", isOn: $fetchAllFolders)
                Text("开启后会扫描邮箱服务器中所有可选择文件夹，并分别记录同步进度。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !fetchAllFolders {
                    TextField("", text: $folder)
                        .sortisCenteredPlaceholder("收件箱文件夹", isEmpty: folder.isEmpty)
                }
            case "telegram":
                SecureField("", text: $botToken)
                    .sortisCenteredPlaceholder("Bot Token", isEmpty: botToken.isEmpty)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            case "rss":
                TextField("", text: $feedUrl)
                    .sortisCenteredPlaceholder("RSS 订阅地址", isEmpty: feedUrl.isEmpty)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            case "http_token":
                Text(receiver == nil ? "创建后会显示真实的 Webhook 地址，可直接选择已有 Token 或创建并自动绑定新 Token。" : "当前接收器支持直接复制 Webhook 地址和 Token 绑定。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if receiver != nil {
                    TextField("", text: .constant(webhookUrl))
                        .sortisCenteredPlaceholder("Webhook URL", isEmpty: webhookUrl.isEmpty)
                        .disabled(true)
                }
            case "websocket":
                Text(receiver == nil ? "创建后会显示真实的 WebSocket 地址，可直接选择已有 Token 或创建并自动绑定新 Token。" : "当前接收器支持直接复制 WebSocket 地址和 Token 绑定。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if receiver != nil {
                    TextField("", text: .constant(webSocketUrl))
                        .sortisCenteredPlaceholder("WebSocket URL", isEmpty: webSocketUrl.isEmpty)
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
        fetchAllFolders = config["fetch_all_folders"] as? Bool ?? false
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
            config["fetch_all_folders"] = fetchAllFolders
            if !fetchAllFolders, !folder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
            if receiver != nil {
                return true
            }
            return selectedTokenId != nil || !tokenName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
    case "email": return "邮件"
    case "telegram": return "Telegram"
    case "rss": return "RSS"
    default: return type
    }
}

private func receiverStatusText(_ status: String) -> String {
    receiverStatusTagText(status)
}

private func receiverStatusColor(_ status: String) -> Color {
    receiverStatusTagColor(status)
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
