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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    VStack(spacing: 8) {
                        Image(systemName: "tray.full.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.sortisPrimary)

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

                    // 服务器地址
                    VStack(alignment: .leading, spacing: 6) {
                        Text("服务器地址")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("例如: http://example.com:8000", text: $viewModel.serverUrl)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }

                    // 用户名
                    VStack(alignment: .leading, spacing: 6) {
                        Text("邮箱")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("请输入邮箱", text: $viewModel.username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }

                    // 密码
                    VStack(alignment: .leading, spacing: 6) {
                        Text("密码")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            if passwordVisible {
                                TextField("请输入密码", text: $viewModel.password)
                                    .textContentType(.password)
                            } else {
                                SecureField("请输入密码", text: $viewModel.password)
                            }
                            Button(action: { passwordVisible.toggle() }) {
                                Image(systemName: passwordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // 错误信息
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // 登录按钮
                    Button(action: {
                        Task {
                            await viewModel.login {
                                appState.isLoggedIn = true
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
                            Text("登录")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.username.isEmpty || viewModel.password.isEmpty ? Color.gray : Color.sortisPrimary)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(viewModel.isLoading || viewModel.username.isEmpty || viewModel.password.isEmpty)

                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}