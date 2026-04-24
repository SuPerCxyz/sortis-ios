//
//  SettingsView.swift
//  Sortis
//
//  设置页面
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var appState: AppState

    @State private var showClearCacheConfirm = false
    @State private var showClearCacheSuccess = false
    @State private var cacheSize: String = "0 KB"

    var body: some View {
        List {
            // 账户信息
            Section(header: Text("账户信息")) {
                LabeledContent {
                    Text(viewModel.username)
                        .foregroundColor(.secondary)
                } label: {
                    HStack(spacing: 10) {
                        SortisSidebarIcon(kind: .userProfile, size: 18, color: .secondary)
                        Text("邮箱")
                    }
                }

                Button(action: {
                    viewModel.draftEmail = viewModel.username
                    viewModel.showEmailDialog = true
                }) {
                    HStack(spacing: 10) {
                        SortisSidebarIcon(kind: .messages, size: 18, color: .secondary)
                        Text("更新邮箱")
                        Spacer()
                    }
                }

                LabeledContent("服务器") {
                    Text(viewModel.serverUrl)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Button(action: {
                    viewModel.showPasswordDialog = true
                }) {
                    HStack(spacing: 10) {
                        SortisSidebarIcon(kind: .lockKeyhole, size: 18, color: .secondary)
                        Text("修改密码")
                        Spacer()
                    }
                }
            }

            // 数据管理
            Section(header: Text("数据管理")) {
                Button(action: { showClearCacheConfirm = true }) {
                    HStack {
                        Text("清除缓存")
                        Spacer()
                        Text(cacheSize)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // 关于
            Section(header: Text("关于")) {
                LabeledContent("版本") {
                    Text(viewModel.appVersion)
                        .foregroundColor(.secondary)
                }

                LabeledContent("构建") {
                    Text(viewModel.buildNumber)
                        .foregroundColor(.secondary)
                }

                Link(destination: URL(string: "https://sortis.app")!) {
                    HStack {
                        Text("官方网站")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.secondary)
                    }
                }
            }

            // 危险操作
            Section {
                Button("退出登录") {
                    viewModel.showLogoutDialog = true
                }
                .foregroundColor(.red)

                Button(action: {
                    viewModel.showDeleteDialog = true
                }) {
                    HStack(spacing: 10) {
                        SortisSidebarIcon(kind: .trashBinMinimalistic, size: 18, color: .red)
                        Text("删除账户")
                        Spacer()
                    }
                }
                .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $viewModel.showPasswordDialog) {
            ChangePasswordSheet(
                onSuccess: { }
            )
        }
        .sheet(isPresented: $viewModel.showEmailDialog) {
            UpdateEmailSheet(viewModel: viewModel)
        }
        .alert("确认退出", isPresented: $viewModel.showLogoutDialog) {
            Button("取消", role: .cancel) {}
            Button("退出", role: .destructive) {
                viewModel.logout()
                appState.isLoggedIn = false
            }
        } message: {
            Text("确定要退出登录吗？")
        }
        .alert("确认删除账户", isPresented: $viewModel.showDeleteDialog) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                viewModel.deleteAccount()
            }
        } message: {
            Text("删除账户将清除所有数据，此操作不可撤销！")
        }
        .alert("提示", isPresented: Binding(
            get: { viewModel.feedbackMessage != nil },
            set: { if !$0 { viewModel.feedbackMessage = nil } }
        )) {
            Button("确定", role: .cancel) {
                if viewModel.feedbackMessage == "账户已删除" {
                    appState.isLoggedIn = false
                }
            }
        } message: {
            Text(viewModel.feedbackMessage ?? "")
        }
        .alert("缓存已清除", isPresented: $showClearCacheSuccess) {
            Button("确定", role: .cancel) {}
        }
        .onAppear {
            calculateCacheSize()
        }
    }

    private func calculateCacheSize() {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        if let size = try? FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: [.fileSizeKey]) {
            let totalSize = size.reduce(0) { result, url in
                let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                return result + fileSize
            }
            cacheSize = ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file)
        }
    }
}

struct UpdateEmailSheet: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("邮箱")) {
                    SortisSettingsIconFieldRow(iconKind: .messages) {
                        TextField("", text: $viewModel.draftEmail)
                            .sortisCenteredPlaceholder("请输入邮箱", isEmpty: viewModel.draftEmail.isEmpty)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                }
            }
            .navigationTitle("更新邮箱")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel.updateEmail()
                    }
                    .disabled(
                        viewModel.isSubmitting ||
                        viewModel.draftEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        viewModel.draftEmail == viewModel.username
                    )
                }
            }
        }
    }
}

// 修改密码弹窗
struct ChangePasswordSheet: View {
    let onSuccess: () -> Void

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("当前密码")) {
                    SortisSettingsIconFieldRow(iconKind: .lockKeyhole) {
                        SecureField("", text: $currentPassword)
                            .sortisCenteredPlaceholder("输入当前密码", isEmpty: currentPassword.isEmpty)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                }

                Section(header: Text("新密码")) {
                    SortisSettingsIconFieldRow(iconKind: .lockKeyhole) {
                        SecureField("", text: $newPassword)
                            .sortisCenteredPlaceholder("输入新密码", isEmpty: newPassword.isEmpty)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                    SortisSettingsIconFieldRow(iconKind: .lockKeyhole) {
                        SecureField("", text: $confirmPassword)
                            .sortisCenteredPlaceholder("确认新密码", isEmpty: confirmPassword.isEmpty)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("修改密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        changePassword()
                    }
                    .disabled(currentPassword.isEmpty || newPassword.isEmpty || newPassword != confirmPassword || isLoading)
                }
            }
            .alert("密码修改成功", isPresented: $showSuccess) {
                Button("确定", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("您的密码已成功修改。")
            }
        }
    }

    private func changePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "两次输入的密码不一致"
            return
        }

        guard newPassword.count >= 6 else {
            errorMessage = "密码长度至少 6 位"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let service = AuthService()
                try await service.changePassword(current: currentPassword, new: newPassword)
                await MainActor.run {
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

private struct SortisSettingsIconFieldRow<Content: View>: View {
    let iconKind: SortisSidebarIconKind
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 10) {
            SortisSidebarIcon(kind: iconKind, size: 18, color: .secondary)
                .frame(width: 18, height: 18)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}
