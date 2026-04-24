//
//  TokensView.swift
//  Sortis
//
//  API Token 管理视图
//

import SwiftUI

struct TokensView: View {
    @StateObject private var viewModel = TokensViewModel()

    @State private var selectedToken: ApiToken?
    @State private var deleteCandidate: ApiToken?

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Menu {
                    ForEach(tokenSearchFieldOptions) { option in
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
                        Text(searchFieldLabel(for: viewModel.searchField, options: tokenSearchFieldOptions))
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
                    .sortisCenteredPlaceholder("搜索 Token", isEmpty: viewModel.searchQuery.isEmpty)
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
            } else if viewModel.tokens.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "key")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("暂无 Token")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                        ForEach(viewModel.tokens) { token in
                            TokenEntityCard(
                                token: token,
                                receivers: viewModel.receivers
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedToken = token
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    viewModel.setEditToken(token)
                                } label: {
                                    Label("编辑", systemImage: "pencil")
                                }
                                .tint(.sortisInfo)

                                Button {
                                    viewModel.revokeOrActivate(tokenId: token.id, isActive: token.isUsable)
                                } label: {
                                    Label(token.toggleActionLabel, systemImage: token.toggleActionSystemImage)
                                }
                                .tint(token.canToggleAction ? .sortisWarning : .gray)
                                .disabled(!token.canToggleAction)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteCandidate = token
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
        .navigationDestination(item: $selectedToken) { token in
            TokenEntityDetailView(token: token, receivers: viewModel.receivers)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.setCreateOpen(true) }) {
                    SortisCreateIcon(size: 18)
                }
            }
        }
        .sheet(isPresented: $viewModel.isCreateOpen) {
            TokenEditDialog(
                token: nil,
                receivers: viewModel.receivers,
                onSave: { name, receiverIds, expiresIn in
                    viewModel.createToken(
                        name: name,
                        receiverIds: receiverIds.isEmpty ? nil : receiverIds,
                        expiresInDays: expiresIn
                    )
                },
                onDismiss: { viewModel.setCreateOpen(false) }
            )
        }
        .sheet(item: $viewModel.editToken) { token in
            TokenEditDialog(
                token: token,
                receivers: viewModel.receivers,
                onSave: { name, _, _ in
                    viewModel.updateToken(tokenId: token.id, name: name)
                },
                onDismiss: { viewModel.setEditToken(nil) }
            )
        }
        .alert("Token 已创建", isPresented: Binding(
            get: { viewModel.createdToken != nil },
            set: { if !$0 { viewModel.createdToken = nil } }
        )) {
            Button("复制") {
                UIPasteboard.general.string = viewModel.createdToken
            }
            Button("关闭", role: .cancel) {
                viewModel.createdToken = nil
            }
        } message: {
            Text("请保存您的 Token，此值只显示一次：\n\(viewModel.createdToken ?? "")")
        }
        .alert("确认删除", isPresented: Binding(
            get: { deleteCandidate != nil },
            set: { if !$0 { deleteCandidate = nil } }
        )) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let token = deleteCandidate {
                    viewModel.deleteToken(tokenId: token.id)
                }
                deleteCandidate = nil
            }
        } message: {
            Text("确定要删除此 Token 吗？")
        }
    }
}

struct TokenCard: View {
    let token: ApiToken
    let receivers: [Receiver]

    private var receiverNames: [String] {
        token.receiverNames ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "key.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.sortisPrimary)

                Text(token.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)

                Spacer()

                FilledTag(
                    text: token.statusText,
                    color: tokenStatusTagColor(token.runtimeStatus)
                )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    if receiverNames.isEmpty {
                        FilledTag(
                            text: "未绑定",
                            color: .chipMutedBackground,
                            textColor: .chipMutedText
                        )
                    } else {
                        ForEach(Array(receiverNames.enumerated()), id: \.offset) { index, name in
                            FilledTag(
                                text: name,
                                color: resolveTokenReceiverTagColor(token: token, receiverName: name, index: index, receivers: receivers)
                            )
                        }
                    }
                }
            }

            Text(maskToken(token.tokenPreview ?? token.token))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)

            HStack {
                Text("上次使用: \(token.lastUsedAt?.formatDateTime() ?? "从未使用")")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Text("创建于: \((token.createdAt ?? "").formatDateTime())")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private func maskToken(_ token: String) -> String {
        if token.count <= 8 {
            return token
        }
        let prefix = String(token.prefix(4))
        let suffix = String(token.suffix(4))
        return "\(prefix)...\(suffix)"
    }
}

struct TokenDetailView: View {
    let token: ApiToken
    let receivers: [Receiver]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(token.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    FilledTag(text: token.statusText, color: tokenStatusTagColor(token.runtimeStatus))
                    FilledTag(
                        text: token.expiresAt?.formatDateTime() ?? "永不过期",
                        color: .chipMutedBackground,
                        textColor: .chipMutedText
                    )
                }

                tokenDetailRow("名称", token.name)
                tokenDetailRow("状态", token.statusText)
                tokenDetailRow("预览", token.tokenPreview ?? token.token)
                if !(token.receiverNames ?? []).isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("绑定接收器")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(Array((token.receiverNames ?? []).enumerated()), id: \.offset) { index, name in
                                    FilledTag(
                                        text: name,
                                        color: resolveTokenReceiverTagColor(token: token, receiverName: name, index: index, receivers: receivers)
                                    )
                                }
                            }
                        }
                    }
                } else {
                    tokenDetailRow("绑定接收器", "未绑定")
                }
                tokenDetailRow("最近使用", token.lastUsedAt?.formatDateTime() ?? "从未使用")
                tokenDetailRow("创建时间", (token.createdAt ?? "").formatDateTime())
                tokenDetailRow("过期时间", token.expiresAt?.formatDateTime() ?? "永不过期")
            }
            .padding(16)
        }
        .navigationTitle("Token 管理")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func tokenDetailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value.isEmpty ? "-" : value)
                .font(.body)
        }
    }

    private func maskToken(_ token: String) -> String {
        if token.count <= 8 {
            return token
        }
        let prefix = String(token.prefix(4))
        let suffix = String(token.suffix(4))
        return "\(prefix)...\(suffix)"
    }
}

private func resolveTokenReceiverTagColor(
    token: ApiToken,
    receiverName: String,
    index: Int,
    receivers: [Receiver]
) -> Color {
    let receiverById =
        (token.receiverIds?.indices.contains(index) == true
            ? receivers.first(where: { $0.id == token.receiverIds?[index] })
            : nil)
        ?? (index == 0
            ? token.receiverId.flatMap { receiverId in receivers.first(where: { $0.id == receiverId }) }
            : nil)
    let receiver = receiverById ?? receivers.first(where: { $0.name == receiverName })
    return receiver.map { receiverTypeTagColor($0.type) } ?? tokenReceiverTagColor(index)
}

struct TokenEditDialog: View {
    let token: ApiToken?
    let receivers: [Receiver]
    let onSave: (String, [Int], Int?) -> Void
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var expiresIn: Int = 0
    @State private var customDays: String = ""
    @State private var selectedReceiverIds: Set<Int> = []

    @Environment(\.dismiss) var dismiss

    let expiryOptions = [
        (0, "永不过期"),
        (7, "7 天"),
        (30, "30 天"),
        (90, "90 天"),
        (365, "1 年"),
        (-1, "自定义")
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("", text: $name)
                        .sortisCenteredPlaceholder("Token 名称", isEmpty: name.isEmpty)
                }

                if token == nil {
                    Section(header: Text("关联接收器")) {
                        if receivers.isEmpty {
                            Text("暂无可选接收器")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(receivers) { receiver in
                                Button {
                                    toggleReceiver(receiver.id)
                                } label: {
                                    HStack {
                                        Text(receiver.name)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if selectedReceiverIds.contains(receiver.id) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.sortisPrimary)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Section(header: Text("有效期")) {
                        Picker("过期时间", selection: $expiresIn) {
                            ForEach(expiryOptions, id: \.0) { value, label in
                                Text(label).tag(value)
                            }
                        }

                        if expiresIn == -1 {
                            HStack {
                                Text("自定义天数")
                                TextField("", text: $customDays)
                                    .sortisCenteredPlaceholder("天数", isEmpty: customDays.isEmpty)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                }

                if let token {
                    Section(header: Text("Token 信息")) {
                        LabeledContent("创建时间") {
                            Text((token.createdAt ?? "").formatDateTime())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if let lastUsed = token.lastUsedAt {
                            LabeledContent("上次使用") {
                                Text(lastUsed.formatDateTime())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(token == nil ? "创建 Token" : "编辑 Token")
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
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let days: Int? = expiresIn == 0 ? nil : (expiresIn == -1 ? Int(customDays) : expiresIn)
                        onSave(trimmedName, Array(selectedReceiverIds), days)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (expiresIn == -1 && Int(customDays) == nil))
                }
            }
        }
        .onAppear {
            if let token {
                name = token.name
                selectedReceiverIds = Set(token.receiverIds ?? [])
            }
        }
    }

    private func toggleReceiver(_ receiverId: Int) {
        if selectedReceiverIds.contains(receiverId) {
            selectedReceiverIds.remove(receiverId)
        } else {
            selectedReceiverIds.insert(receiverId)
        }
    }
}
