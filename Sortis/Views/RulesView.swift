//
//  RulesView.swift
//  Sortis
//
//  分类规则视图
//

import SwiftUI

struct RulesView: View {
    @StateObject private var viewModel = RulesViewModel()

    @State private var selectedRule: Rule?
    @State private var deleteCandidate: Rule?
    @State private var showReclassifyConfirm = false

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Menu {
                    ForEach(ruleSearchFieldOptions) { option in
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
                        Text(searchFieldLabel(for: viewModel.searchField, options: ruleSearchFieldOptions))
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
                    .sortisCenteredPlaceholder("搜索规则", isEmpty: viewModel.searchQuery.isEmpty)
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
            } else if viewModel.rules.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("暂无规则")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                        ForEach(viewModel.rules) { rule in
                            RuleEntityCard(rule: rule)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedRule = rule
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        viewModel.setActionRule(rule)
                                    } label: {
                                        Label("编辑", systemImage: "pencil")
                                    }
                                    .tint(.sortisInfo)

                                    Button {
                                        viewModel.toggleRuleEnabled(ruleId: rule.id)
                                    } label: {
                                        Label(rule.isEnabled ? "停用" : "启用", systemImage: rule.isEnabled ? "pause.fill" : "play.fill")
                                    }
                                    .tint(.sortisWarning)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deleteCandidate = rule
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
        .navigationDestination(item: $selectedRule) { rule in
            RuleEntityDetailView(rule: rule, categories: viewModel.categories)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button(action: { showReclassifyConfirm = true }) {
                        SortisRefreshIcon(size: 18, color: .accentColor)
                    }
                    Button(action: {
                        viewModel.setActionRule(Rule(
                            id: 0,
                            name: "",
                            categoryId: 0,
                            matchType: "all",
                            conditions: [],
                            isEnabled: true,
                            titleTemplate: nil,
                            contentTemplate: nil,
                            createdAt: "",
                            updatedAt: nil
                        ))
                    }) {
                        SortisCreateIcon(size: 18)
                    }
                }
            }
        }
        .sheet(item: $viewModel.actionRule) { rule in
            if rule.id == 0 {
                // 创建新规则
                RuleEditDialog(
                    rule: nil,
                    categories: viewModel.categories,
                    onSave: { name, categoryId, matchType, conditions, titleTemplate, contentTemplate in
                        viewModel.createRule(
                            name: name,
                            description: nil,
                            categoryId: categoryId,
                            matchType: matchType,
                            conditions: conditions,
                            isEnabled: true,
                            titleTemplate: titleTemplate,
                            contentTemplate: contentTemplate
                        )
                    },
                    onDismiss: { viewModel.setActionRule(nil) }
                )
            } else {
                // 编辑规则
                RuleEditDialog(
                    rule: rule,
                    categories: viewModel.categories,
                    onSave: { name, categoryId, matchType, conditions, titleTemplate, contentTemplate in
                        viewModel.updateRule(
                            ruleId: rule.id,
                            name: name,
                            description: nil,
                            categoryId: categoryId,
                            matchType: matchType,
                            conditions: conditions,
                            isEnabled: rule.isEnabled,
                            titleTemplate: titleTemplate,
                            contentTemplate: contentTemplate
                        )
                    },
                    onDismiss: { viewModel.setActionRule(nil) }
                )
            }
        }
        .alert("确认删除", isPresented: Binding(
            get: { deleteCandidate != nil },
            set: { if !$0 { deleteCandidate = nil } }
        )) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let rule = deleteCandidate, rule.id != 0 {
                    viewModel.deleteRule(ruleId: rule.id)
                }
                deleteCandidate = nil
            }
        } message: {
            Text("确定要删除此规则吗？")
        }
        .alert("重新分类", isPresented: $showReclassifyConfirm) {
            Button("取消", role: .cancel) {}
            Button("确认") {
                viewModel.recategorizeRules()
            }
        } message: {
            Text("将根据所有启用的规则重新分类现有消息，此操作可能需要一些时间。")
        }
    }
}

// 规则卡片
struct RuleCard: View {
    let rule: Rule

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(rule.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)

                Spacer()
                FilledTag(
                    text: rule.isEnabled ? "启用中" : "已停用",
                    color: rule.isEnabled ? .chipSuccess : .chipWarning
                )
            }

            // 分类信息
            if let category = rule.category {
                FilledTag(text: category.name, color: categoryTagColor(category.color))
            }

            // 条件预览
            if !rule.conditions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(rule.conditions, id: \.id) { condition in
                            ConditionChip(condition: condition)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct RuleDetailView: View {
    let rule: Rule
    let categories: [Category]

    private var targetCategoryDetail: RuleTargetCategoryDetail? {
        if let category = categories.first(where: { $0.id == rule.categoryId }) {
            return RuleTargetCategoryDetail(
                name: category.name,
                path: category.fullPath?.isEmpty == false ? category.fullPath! : category.name,
                level: category.level,
                unreadCount: category.unreadCount,
                readCount: category.readCount,
                totalCount: category.totalCount
            )
        }

        if let fallbackName = rule.category?.name, !fallbackName.isEmpty {
            return RuleTargetCategoryDetail(
                name: fallbackName,
                path: fallbackName,
                level: 0,
                unreadCount: 0,
                readCount: 0,
                totalCount: 0
            )
        }

        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(rule.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    if let category = rule.category {
                        FilledTag(text: category.name, color: categoryTagColor(category.color))
                    }

                    FilledTag(text: rule.isEnabled ? "启用中" : "已停用", color: rule.isEnabled ? .chipSuccess : .chipWarning)
                }

                detailRow("规则名称", rule.name)
                detailRow("目标分类", targetCategoryDetail?.name ?? "未设置")
                detailRow("状态", rule.isEnabled ? "启用" : "停用")
                detailRow("创建时间", (rule.createdAt ?? "").formatDateTime())
                detailRow("更新时间", (rule.updatedAt ?? "").formatDateTime())

                if let description = rule.description, !description.isEmpty {
                    detailSection("描述", description)
                }

                detailSection(
                    "匹配条件",
                    rule.conditions.map { "\(ruleFieldName($0.field, keyPath: $0.keyPath)) \(ruleOperatorName($0.op)) \(String(describing: $0.value.value))" }
                        .joined(separator: "\n")
                )

                if (rule.titleTemplate?.isEmpty == false) || (rule.contentTemplate?.isEmpty == false) {
                    detailSection(
                        "信息模板",
                        [
                            "标题模板：\(rule.titleTemplate?.isEmpty == false ? rule.titleTemplate! : "未设置")",
                            "正文模板：\(rule.contentTemplate?.isEmpty == false ? rule.contentTemplate! : "未设置")"
                        ].joined(separator: "\n\n")
                    )
                }

                if let targetCategoryDetail {
                    detailSection(
                        "目标分类详情",
                        [
                            "路径：\(targetCategoryDetail.path)",
                            targetCategoryDetail.level > 0 ? "层级：\(targetCategoryDetail.level)" : nil,
                            "未读：\(targetCategoryDetail.unreadCount)",
                            "已读：\(targetCategoryDetail.readCount)",
                            "总计：\(targetCategoryDetail.totalCount)"
                        ]
                            .compactMap { $0 }
                            .joined(separator: "\n")
                    )
                }
            }
            .padding(16)
        }
        .navigationTitle("分类规则")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value.isEmpty ? "-" : value)
                .font(.body)
        }
    }

    private func detailSection(_ title: String, _ content: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(content.isEmpty ? "-" : content)
                .font(.body)
        }
    }
}

private struct RuleTargetCategoryDetail {
    let name: String
    let path: String
    let level: Int
    let unreadCount: Int
    let readCount: Int
    let totalCount: Int
}

private func ruleFieldName(_ field: String, keyPath: String? = nil) -> String {
    let label: String
    switch field {
    case "title": label = "标题"
    case "content": label = "内容"
    case "source_name": label = "发件人名称"
    case "source_address": label = "发件人地址"
    case "raw_data": label = "原始 JSON"
    case "has_attachments": label = "是否有附件"
    default: label = field
    }
    if field == "raw_data", let keyPath, !keyPath.isEmpty {
        return "\(label)(\(keyPath))"
    }
    return label
}

private func ruleOperatorName(_ op: String) -> String {
    switch op {
    case "contains": return "包含"
    case "equals": return "等于"
    case "startswith": return "开头为"
    case "endswith": return "结尾为"
    case "regex": return "匹配"
    case "not_equals": return "不等于"
    case "not_contains": return "不包含"
    default: return op
    }
}

// 条件标签
struct ConditionChip: View {
    let condition: RuleCondition

    var body: some View {
        HStack(spacing: 2) {
            Text(ruleFieldName(condition.field, keyPath: condition.keyPath))
                .font(.caption2)
            Text(getOperatorSymbol(condition.operator))
                .font(.caption2)
            Text(formatValue(condition.value))
                .font(.caption2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .foregroundColor(.white)
        .background(Color.sortisPrimary)
        .cornerRadius(4)
    }

    private func getOperatorSymbol(_ op: String) -> String {
        switch op {
        case "contains": return "包含"
        case "equals": return "等于"
        case "startswith": return "开头"
        case "endswith": return "结尾"
        case "regex": return "匹配"
        case "not_equals": return "不等于"
        case "not_contains": return "不包含"
        default: return op
        }
    }

    private func formatValue(_ value: AnyEncodable) -> String {
        if let s = value.value as? String {
            return s.count > 10 ? String(s.prefix(10)) + "..." : s
        }
        return "\(value.value)"
    }
}

// 规则编辑对话框
struct RuleEditDialog: View {
    let rule: Rule?
    let categories: [Category]
    let onSave: (String, Int, String, [RuleConditionDraft], String?, String?) -> Void
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var categoryId: Int = 0
    @State private var matchType: String = "all"
    @State private var titleTemplate: String = ""
    @State private var contentTemplate: String = ""
    @State private var conditions: [RuleConditionDraft] = []

    @Environment(\.dismiss) var dismiss

    let fieldOptions = ["title", "content", "source_name", "source_address", "raw_data", "has_attachments"]
    let operatorOptions = ["contains", "equals", "startswith", "endswith", "regex", "not_equals", "not_contains"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("", text: $name)
                        .sortisCenteredPlaceholder("规则名称", isEmpty: name.isEmpty)

                    Picker("目标分类", selection: $categoryId) {
                        Text("请选择分类").tag(0)
                        ForEach(categories, id: \.id) { cat in
                            Text(cat.name).tag(cat.id)
                        }
                    }
                }

                Section(header: Text("匹配条件")) {
                    Picker("匹配方式", selection: $matchType) {
                        Text("全部条件都满足").tag("all")
                        Text("任一条件满足").tag("any")
                    }

                    ForEach(conditions.indices, id: \.self) { index in
                        ConditionRow(
                            condition: $conditions[index],
                            fieldOptions: fieldOptions,
                            operatorOptions: operatorOptions
                        )
                    }
                    .onDelete { indices in
                        conditions.remove(atOffsets: indices)
                    }

                    Button(action: {
                        conditions.append(RuleConditionDraft(
                            field: "title",
                            op: "contains",
                            keyPath: "",
                            value: ""
                        ))
                    }) {
                        HStack(spacing: 6) {
                            SortisCreateIcon(size: 14)
                            Text("添加条件")
                        }
                    }
                }

                Section(header: Text("信息模板")) {
                    TextField("", text: $titleTemplate, axis: .vertical)
                        .sortisCenteredPlaceholder("标题模板", isEmpty: titleTemplate.isEmpty)
                    TextField("", text: $contentTemplate, axis: .vertical)
                        .sortisCenteredPlaceholder("正文模板", isEmpty: contentTemplate.isEmpty)
                    Text("支持 {{raw_data.xxx}}、{{title}}、{{content}}、{{source_name}}、{{source_address}}")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(rule == nil ? "新建规则" : "编辑规则")
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
                            name,
                            categoryId,
                            matchType,
                            conditions,
                            titleTemplate.isEmpty ? nil : titleTemplate,
                            contentTemplate.isEmpty ? nil : contentTemplate
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty || categoryId == 0 || conditions.isEmpty)
                }
            }
        }
        .onAppear {
            if let rule = rule {
                name = rule.name
                categoryId = rule.categoryId
                matchType = rule.matchType
                titleTemplate = rule.titleTemplate ?? ""
                contentTemplate = rule.contentTemplate ?? ""
                conditions = rule.conditions.map { RuleConditionDraft(
                    field: $0.field,
                    op: $0.op,
                    keyPath: $0.keyPath ?? "",
                    value: ($0.value.value as? String) ?? ""
                ) }
            }
        }
    }
}

// 条件草稿
struct RuleConditionDraft {
    var field: String
    var op: String  // 使用 op 避免关键字问题
    var keyPath: String
    var value: String
}

// 条件编辑行
struct ConditionRow: View {
    @Binding var condition: RuleConditionDraft
    let fieldOptions: [String]
    let operatorOptions: [String]

    var body: some View {
        VStack(spacing: 8) {
            Picker("字段", selection: $condition.field) {
                ForEach(fieldOptions, id: \.self) { field in
                    Text(getFieldName(field)).tag(field)
                }
            }

            Picker("操作", selection: $condition.op) {
                ForEach(operatorOptions, id: \.self) { op in
                    Text(getOperatorName(op)).tag(op)
                }
            }

            if condition.field == "raw_data" {
                HStack {
                    Text("Key:")
                    TextField("", text: $condition.keyPath)
                        .sortisCenteredPlaceholder("例如 alert.labels.instance", isEmpty: condition.keyPath.isEmpty)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }

            HStack {
                Text("值:")
                TextField("", text: $condition.value)
                    .sortisCenteredPlaceholder("输入匹配值", isEmpty: condition.value.isEmpty)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding(.vertical, 4)
    }

    private func getFieldName(_ field: String) -> String {
        switch field {
        case "title": return "标题"
        case "content": return "内容"
        case "source_name": return "发件人名称"
        case "source_address": return "发件人地址"
        case "raw_data": return "原始 JSON"
        case "has_attachments": return "是否有附件"
        default: return field
        }
    }

    private func getOperatorName(_ op: String) -> String {
        switch op {
        case "contains": return "包含"
        case "equals": return "等于"
        case "startswith": return "开头为"
        case "endswith": return "结尾为"
        case "regex": return "正则匹配"
        case "not_equals": return "不等于"
        case "not_contains": return "不包含"
        default: return op
        }
    }
}
