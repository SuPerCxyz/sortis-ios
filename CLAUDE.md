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

# 命令行构建 (模拟器)
xcodebuild -project Sortis.xcodeproj -scheme Sortis -destination 'platform=iOS Simulator,name=iPhone 15' build

# 运行测试
xcodebuild -project Sortis.xcodeproj -scheme Sortis -destination 'platform=iOS Simulator,name=iPhone 15' test
```

### CI/CD 构建
- GitHub Actions 自动构建：`.github/workflows/ios-build.yml`
- 构建产物：Sortis-iOS-Simulator.zip (模拟器) 和 Sortis-Unsigned.ipa (设备)
- 下载地址：https://github.com/SuPerCxyz/sortis-ios/actions

### 构建验证记录

#### 2026-03-27 v1.0.0 验证完成

**构建产物：**
| 平台 | 产物 | 大小 | 状态 |
|------|------|------|------|
| iOS 模拟器 | Sortis-iOS-Simulator.zip | 1.4MB | ✅ 成功 |
| iOS 设备 | Sortis-Unsigned.ipa | 448KB | ✅ 成功 |
| Android | sortis-dev-0.0.1-alpha.37.apk | 16MB | ✅ 成功 |

**验证环境：**
- 主机: Ubuntu 24.04.4 LTS (Linux x86_64)
- Android 模拟器: sdk_gphone64_x86_64, Android 14 (API 34)
- 后端: localhost:8000 正常响应

**iOS 功能对比 (代码层面)：**
| 功能 | iOS | Android | 状态 |
|------|-----|---------|------|
| 登录认证 | ✅ | ✅ | 一致 |
| 信息视图/分类导航 | ✅ | ✅ | 一致 |
| 消息列表/详情/操作 | ✅ | ✅ | 一致 |
| 分类管理 CRUD | ✅ | ✅ | 一致 |
| 规则管理 | ✅ | ✅ | 一致 |
| 接收器管理 | ✅ | ✅ | 一致 |
| Token 管理 | ✅ | ✅ | 一致 |
| 设置/帮助页面 | ✅ | ✅ | 一致 |

**限制说明：**
- Linux 无法运行 iOS 模拟器，iOS 真机验证需 macOS 或 Corellium
- 无头模式 Android 模拟器服务稳定性受限，建议使用 GUI 环境测试

### 构建验证要求
- 每次修改完成后，必须通过 GitHub Actions CI 构建验证
- 回归完成后必须回报：构建版本号、产物大小、验证结果

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
3. **验证流程**: 修改后通过 GitHub Actions CI 构建验证
4. **代码一致性**: 遵循现有代码风格，不引入无关依赖

## Swift 开发注意事项

### 已解决的编译问题
1. **关键字冲突**: `operator` 是 Swift 保留字，使用 `op` 代替
2. **类型命名冲突**: `CategoryInfo` 在多个文件中定义，使用 `RuleCategoryInfo` 区分
3. **Optional 解包**: Optional 类型调用方法前必须解包（如 `token.createdAt?.method()` 或 `(token.createdAt ?? "").method()`）
4. **ActionSheet 限制**: SwiftUI 的 ActionSheet 类型不能使用 `.sheet` 修饰符，需改用自定义视图或 confirmationDialog
5. **async 上下文**: 在非 async 函数中调用 async 函数需使用 `Task { await ... }`
6. **参数标签**: 调用函数时必须使用参数标签（如 `getStatsOverview(days: 7)` 而非 `getStatsOverview(7)`）
7. **self 捕获**: Task 闭包中访问实例属性需使用 `[weak self]` 并解包

### Swift 关键字列表 (禁止用作属性名)
`operator`, `type`, `class`, `struct`, `enum`, `protocol`, `func`, `var`, `let`, `import`, `return`, `if`, `else`, `for`, `while`, `do`, `try`, `catch`, `switch`, `case`, `default`, `break`, `continue`, `private`, `public`, `internal`, `static`, `self`, `super`, `nil`, `true`, `false`