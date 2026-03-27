//
//  TokensView.swift
//  Sortis
//
//  API Token 管理视图
//

import SwiftUI

struct TokensView: View {
    @StateObject private var viewModel = TokensViewModel()

    @State private var showDeleteConfirm = false

    var body: some View {
        VStack {
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
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.tokens) { token in
                            TokenCard(
                                token: token,
                                onToggle: { viewModel.revokeOrActivate(tokenId: token.id, isActive: token.isActive) },
                                onEdit: { viewModel.setEditToken(token) },
                                onDelete: {
                                    viewModel.setActionToken(token)
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
            TokenEditDialog(
                token: nil,
                onSave: { name, expiresIn in
                    viewModel.createToken(name: name, receiverIds: nil, expiresInDays: expiresIn)
                },
                onDismiss: { viewModel.setCreateOpen(false) }
            )
        }
        .sheet(item: $viewModel.editToken) { token in
            TokenEditDialog(
                token: token,
                onSave: { name, _ in
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
        .alert("确认删除", isPresented: $showDeleteConfirm) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let token = viewModel.actionToken {
                    viewModel.deleteToken(tokenId: token.id)
                }
            }
        } message: {
            Text("确定要删除此 Token 吗？")
        }
    }
}

// Token 卡片
struct TokenCard: View {
    let token: ApiToken
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

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

                // 状态
                Text(token.isActive ? "活跃" : "停用")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(token.isActive ? Color.sortisSuccess.opacity(0.2) : Color.secondary.opacity(0.2))
                    .foregroundColor(token.isActive ? .sortisSuccess : .secondary)
                    .cornerRadius(4)
            }

            // Token 值（部分隐藏）
            Text(maskToken(token.token))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)

            // 底部信息
            HStack {
                if let lastUsed = token.lastUsedAt {
                    Text("上次使用: \(lastUsed.formatDateTime())")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("创建于: \(token.createdAt.formatDateTime())")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            // 操作按钮
            HStack {
                Spacer()

                Toggle("", isOn: Binding(
                    get: { token.isActive },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .scaleEffect(0.7)

                Menu {
                    Button(action: onEdit) {
                        Label("编辑", systemImage: "pencil")
                    }
                    Button {
                        UIPasteboard.general.string = token.token
                    } label: {
                        Label("复制 Token", systemImage: "doc.on.doc")
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

// Token 编辑对话框
struct TokenEditDialog: View {
    let token: ApiToken?
    let onSave: (String, Int?) -> Void
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var expiresIn: Int = 0
    @State private var customDays: String = ""

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
                    TextField("Token 名称", text: $name)
                }

                if token == nil {
                    Section(header: Text("有效期")) {
                        Picker("过期时间", selection: $expiresIn) {
                            ForEach(expiryOptions, id: \.0) { value, label in
                                Text(label).tag(value)
                            }
                        }

                        if expiresIn == -1 {
                            HStack {
                                Text("自定义天数")
                                TextField("天数", text: $customDays)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                }

                if let token = token {
                    Section(header: Text("Token 信息")) {
                        LabeledContent("创建时间") {
                            Text(token.createdAt.formatDateTime())
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
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let days: Int? = expiresIn == 0 ? nil : (expiresIn == -1 ? Int(customDays) : expiresIn)
                        onSave(name, days)
                        dismiss()
                    }
                    .disabled(name.isEmpty || (expiresIn == -1 && Int(customDays) == nil))
                }
            }
        }
        .onAppear {
            if let token = token {
                name = token.name
            }
        }
    }
}