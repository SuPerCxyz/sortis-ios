//
//  LoginView.swift
//  Sortis
//
//  登录页面
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var appState: AppState

    @State private var passwordVisible = false
    @State private var confirmPasswordVisible = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    VStack(spacing: 8) {
                        Image("SortisLogo", bundle: AppAssets.bundle)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)

                        Text("Sortis")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.sortisPrimary)

                        Text("消息聚合管理")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    Text(viewModel.isRegisterMode ? "注册新账户" : "登录账户")
                        .font(.headline)

                    // 服务器地址
                    VStack(alignment: .leading, spacing: 6) {
                        Text("服务器地址")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField(
                            "",
                            text: Binding(
                                get: { viewModel.serverUrl },
                                set: { viewModel.updateServerUrl($0) }
                            )
                        )
                            .sortisCenteredPlaceholder("例如: http://example.com:8000", isEmpty: viewModel.serverUrl.isEmpty)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }

                    // 用户名
                    VStack(alignment: .leading, spacing: 6) {
                        SortisLoginFieldCaption(iconKind: .messages, text: "邮箱")
                        SortisLoginIconFieldRow(iconKind: .messages) {
                            TextField("", text: $viewModel.username)
                                .sortisCenteredPlaceholder("请输入邮箱", isEmpty: viewModel.username.isEmpty)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                    }

                    // 密码
                    VStack(alignment: .leading, spacing: 6) {
                        SortisLoginFieldCaption(iconKind: .lockKeyhole, text: "密码")
                        SortisLoginIconFieldRow(iconKind: .lockKeyhole) {
                            if passwordVisible {
                                TextField("", text: $viewModel.password)
                                    .sortisCenteredPlaceholder("请输入密码", isEmpty: viewModel.password.isEmpty)
                                    .textContentType(.password)
                            } else {
                                SecureField("", text: $viewModel.password)
                                    .sortisCenteredPlaceholder("请输入密码", isEmpty: viewModel.password.isEmpty)
                            }
                            Button(action: { passwordVisible.toggle() }) {
                                Image(systemName: passwordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    if viewModel.isRegisterMode {
                        VStack(alignment: .leading, spacing: 6) {
                            SortisLoginFieldCaption(iconKind: .lockKeyhole, text: "确认密码")
                            SortisLoginIconFieldRow(iconKind: .lockKeyhole) {
                                if confirmPasswordVisible {
                                    TextField("", text: $viewModel.confirmPassword)
                                        .sortisCenteredPlaceholder("请再次输入密码", isEmpty: viewModel.confirmPassword.isEmpty)
                                        .textContentType(.password)
                                } else {
                                    SecureField("", text: $viewModel.confirmPassword)
                                        .sortisCenteredPlaceholder("请再次输入密码", isEmpty: viewModel.confirmPassword.isEmpty)
                                }
                                Button(action: { confirmPasswordVisible.toggle() }) {
                                    Image(systemName: confirmPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    // 错误信息
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let success = viewModel.successMessage {
                        Text(success)
                            .font(.caption)
                            .foregroundColor(.sortisPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !viewModel.isRegistrationEnabled {
                        Text("当前服务端已关闭注册")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: {
                        Task {
                            if viewModel.isRegisterMode {
                                await viewModel.register()
                            } else {
                                await viewModel.login {
                                    appState.isLoggedIn = true
                                }
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.sortisPrimary)
                                .cornerRadius(10)
                        } else {
                            Text(viewModel.isRegisterMode ? "注册" : "登录")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    viewModel.username.isEmpty
                                        || viewModel.password.isEmpty
                                        || (viewModel.isRegisterMode && viewModel.confirmPassword.isEmpty)
                                        ? Color.gray
                                        : Color.sortisPrimary
                                )
                                .cornerRadius(10)
                        }
                    }
                    .disabled(
                        viewModel.isLoading
                            || viewModel.username.isEmpty
                            || viewModel.password.isEmpty
                            || (viewModel.isRegisterMode && viewModel.confirmPassword.isEmpty)
                    )

                    if viewModel.isRegistrationEnabled || viewModel.isRegisterMode {
                        Button(viewModel.isRegisterMode ? "已有账户，去登录" : "没有账户，去注册") {
                            viewModel.toggleMode()
                        }
                        .font(.subheadline)
                    }

                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

private struct SortisLoginFieldCaption: View {
    let iconKind: SortisSidebarIconKind
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            SortisSidebarIcon(kind: iconKind, size: 14, color: .secondary)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private struct SortisLoginIconFieldRow<Content: View>: View {
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}
