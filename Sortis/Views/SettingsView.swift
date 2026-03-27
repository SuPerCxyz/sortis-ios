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
                LabeledContent("邮箱") {
                    Text(viewModel.username)
                        .foregroundColor(.secondary)
                }

                LabeledContent("服务器") {
                    Text(viewModel.serverUrl)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Button("修改密码") {
                    viewModel.showPasswordDialog = true
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

                Button("删除账户") {
                    viewModel.showDeleteDialog = true
                }
                .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $viewModel.showPasswordDialog) {
            ChangePasswordSheet(
                onSuccess: { }
            )
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
                appState.isLoggedIn = false
            }
        } message: {
            Text("删除账户将清除所有数据，此操作不可撤销！")
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
                    SecureField("输入当前密码", text: $currentPassword)
                }

                Section(header: Text("新密码")) {
                    SecureField("输入新密码", text: $newPassword)
                    SecureField("确认新密码", text: $confirmPassword)
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