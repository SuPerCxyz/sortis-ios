# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Sortis iOS App 是一个消息聚合应用的 iOS 客户端，使用 SwiftUI 构建，支持 Webhook、Email、Telegram、RSS 等多种消息接收方式。

## 构建与运行

### 开发环境要求
- Xcode 15.0+
- iOS 17.0+
- Swift 5.0+

### 构建命令
```bash
# 打开项目
open Sortis.xcodeproj

# 命令行构建
xcodebuild -project Sortis.xcodeproj -scheme Sortis -destination 'platform=iOS Simulator,name=iPhone 15' build

# 运行测试
xcodebuild -project Sortis.xcodeproj -scheme Sortis -destination 'platform=iOS Simulator,name=iPhone 15' test
```

### 构建验证要求
- 每次修改完成后，必须在模拟器或真机上安装并验证改动是否生效
- 回归完成后必须回报：构建版本号、验证结果

## 项目结构

```
Sortis/
├── SortisApp.swift           # 应用入口，AppState 管理登录状态
├── Models/                   # 数据模型 (Codable)
│   ├── Auth.swift           # 登录请求/响应
│   ├── Category.swift       # 分类模型，FlatCategory 用于列表显示
│   ├── Message.swift        # 消息模型
│   ├── Rule.swift           # 规则模型，AnyEncodable 支持灵活 JSON
│   ├── Receiver.swift       # 接收器模型，AnyCodable 支持动态配置
│   └── ApiToken.swift       # API Token 模型
├── Services/                 # 网络服务层
│   ├── APIClient.swift      # URLSession 封装，GET/POST/PUT/DELETE
│   ├── AuthService.swift    # 登录认证，Token 管理
│   ├── CategoryService.swift
│   ├── MessageService.swift # 消息列表，getAllMessages 分页加载
│   ├── RuleService.swift
│   ├── ReceiverService.swift
│   ├── TokenService.swift
│   └── StatsService.swift
├── ViewModels/               # MVVM 架构
│   ├── LoginViewModel.swift
│   ├── MainViewModel.swift  # 导航路由
│   ├── ViewViewModel.swift  # 分类导航和消息列表
│   ├── AllMessagesViewModel.swift
│   ├── CategoriesViewModel.swift
│   ├── RulesViewModel.swift
│   ├── ReceiversViewModel.swift
│   ├── TokensViewModel.swift
│   └── SettingsViewModel.swift
├── Views/                    # SwiftUI 视图
│   ├── LoginView.swift
│   ├── MainView.swift       # 主布局，侧边栏导航，DashboardView
│   ├── ViewScreen.swift     # 分类导航，CategoryMessagesView
│   ├── AllMessagesView.swift # Tab 消息列表
│   ├── CategoriesView.swift
│   ├── RulesView.swift
│   ├── ReceiversView.swift
│   ├── TokensView.swift
│   ├── SettingsView.swift
│   └── HelpView.swift
├── Components/               # 可复用组件
│   └── MessageCard.swift    # 消息卡片，详情弹窗，操作菜单
├── Theme/
│   ├── AppTheme.swift       # 主题常量 (抽屉宽度 220pt)
│   └── Colors.swift         # 颜色定义 (#667EEA, #764BA2 渐变)
├── Utils/
│   ├── KeychainManager.swift # Token 安全存储
│   ├── TokenManager.swift   # Token 管理封装
│   └── DateFormatter.swift  # 日期格式化扩展
└── Assets.xcassets/         # 资源文件
```

## 关键技术点

### 网络请求
- APIClient 使用 URLSession，支持 Bearer Token 认证
- 服务器地址存储在 UserDefaults，Key: "serverUrl"
- 所有请求自动添加 Authorization header

### Token 管理
- Keychain 存储 JWT Token
- TokenManager 提供 save/get/clear/hasToken 方法
- AppState 监听登录状态

### 数据模型
- AnyEncodable/AnyCodable 用于处理动态 JSON
- Rule.conditions 支持数组或嵌套对象两种格式
- FlatCategory 用于分类列表缩进显示

### UI 规范
- 抽屉菜单宽度: 220pt
- Logo 紫色渐变: #667EEA → #764BA2
- 卡片圆角: 10pt
- 消息列表分页: 每次请求 10,000 条

## 关联项目

```
/home/superc/code/
├── sortis          # 后端 + Web 管理端
├── sortis-android  # Android 客户端
└── sortis-ios      # iOS 客户端（当前项目）
```

- API 定义参考: `/home/superc/code/sortis-android/app/src/main/java/com/sortis/app/data/api/SortisApi.kt`
- 数据模型参考: `/home/superc/code/sortis-android/app/src/main/java/com/sortis/app/data/model/Models.kt`
- 后端 API: `/home/superc/code/sortis/backend/app/api/`

## AI 工作指引

1. **交互语言**: 一律使用中文
2. **改动范围**: 仅修改业务逻辑时禁止擅自修改 UI/样式/布局
3. **验证流程**: 修改后在模拟器或真机上验证
4. **代码一致性**: 遵循现有代码风格，不引入无关依赖