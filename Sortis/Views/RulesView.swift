//
//  RulesView.swift
//  Sortis
//
//  分类规则视图
//

import SwiftUI

struct RulesView: View {
    @StateObject private var viewModel = RulesViewModel()

    @State private var showDeleteConfirm = false
    @State private var showReclassifyConfirm = false

    var body: some View {
        VStack {
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
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.rules) { rule in
                            RuleCard(
                                rule: rule,
                                onToggle: { viewModel.toggleRuleEnabled(ruleId: rule.id) },
                                onEdit: { viewModel.setEditRule(rule) },
                                onDelete: {
                                    viewModel.setActionRule(rule)
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
                HStack(spacing: 12) {
                    Button(action: { showReclassifyConfirm = true }) {
                        Text("重新分类")
                            .font(.caption)
                    }
                    Button(action: {
                        viewModel.setActionRule(Rule(
                            id: 0,
                            name: "",
                            categoryId: 0,
                            conditions: [],
                            isEnabled: true,
                            createdAt: "",
                            updatedAt: nil
                        ))
                    }) {
                        Image(systemName: "plus")
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
                    onSave: { name, categoryId, conditions in
                        viewModel.createRule(
                            name: name,
                            description: nil,
                            categoryId: categoryId,
                            priority: 0,
                            matchType: "all",
                            conditions: conditions,
                            isEnabled: true
                        )
                    },
                    onDismiss: { viewModel.setActionRule(nil) }
                )
            } else {
                // 编辑规则
                RuleEditDialog(
                    rule: rule,
                    categories: viewModel.categories,
                    onSave: { name, categoryId, conditions in
                        viewModel.updateRule(
                            ruleId: rule.id,
                            name: name,
                            description: nil,
                            categoryId: categoryId,
                            priority: 0,
                            matchType: "all",
                            conditions: conditions,
                            isEnabled: rule.isEnabled
                        )
                    },
                    onDismiss: { viewModel.setActionRule(nil) }
                )
            }
        }
        .alert("确认删除", isPresented: $showDeleteConfirm) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let rule = viewModel.actionRule, rule.id != 0 {
                    viewModel.deleteRule(ruleId: rule.id)
                }
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
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(rule.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)

                Spacer()

                // 状态开关
                Toggle("", isOn: Binding(
                    get: { rule.isEnabled },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .scaleEffect(0.8)

                Menu {
                    Button(action: onEdit) {
                        Label("编辑", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
            }

            // 分类信息
            if let category = rule.category {
                HStack(spacing: 4) {
                    Image(systemName: "folder.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(category.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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

// 条件标签
struct ConditionChip: View {
    let condition: RuleCondition

    var body: some View {
        HStack(spacing: 2) {
            Text(condition.field)
                .font(.caption2)
            Text(getOperatorSymbol(condition.operator))
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(formatValue(condition.value))
                .font(.caption2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.sortisPrimary.opacity(0.1))
        .cornerRadius(4)
    }

    private func getOperatorSymbol(_ op: String) -> String {
        switch op {
        case "contains": return "包含"
        case "equals": return "等于"
        case "startsWith": return "开头"
        case "endsWith": return "结尾"
        case "matches": return "匹配"
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
    let onSave: (String, Int, [RuleConditionDraft]) -> Void
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var categoryId: Int = 0
    @State private var conditions: [RuleConditionDraft] = []

    @Environment(\.dismiss) var dismiss

    let fieldOptions = ["title", "content", "sourceName", "sourceType"]
    let operatorOptions = ["contains", "equals", "startsWith", "endsWith", "matches"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("规则名称", text: $name)

                    Picker("目标分类", selection: $categoryId) {
                        Text("请选择分类").tag(0)
                        ForEach(categories, id: \.id) { cat in
                            Text(cat.name).tag(cat.id)
                        }
                    }
                }

                Section(header: Text("匹配条件")) {
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
                            operator: "contains",
                            value: ""
                        ))
                    }) {
                        Label("添加条件", systemImage: "plus.circle")
                    }
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
                        onSave(name, categoryId, conditions)
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
                conditions = rule.conditions.map { RuleConditionDraft(
                    field: $0.field,
                    operator: $0.operator,
                    value: ($0.value.value as? String) ?? ""
                ) }
            }
        }
    }
}

// 条件草稿
struct RuleConditionDraft {
    var field: String
    var operator: String
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

            Picker("操作", selection: $condition.operator) {
                ForEach(operatorOptions, id: \.self) { op in
                    Text(getOperatorName(op)).tag(op)
                }
            }

            HStack {
                Text("值:")
                TextField("输入匹配值", text: $condition.value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding(.vertical, 4)
    }

    private func getFieldName(_ field: String) -> String {
        switch field {
        case "title": return "标题"
        case "content": return "内容"
        case "sourceName": return "来源名称"
        case "sourceType": return "来源类型"
        default: return field
        }
    }

    private func getOperatorName(_ op: String) -> String {
        switch op {
        case "contains": return "包含"
        case "equals": return "等于"
        case "startsWith": return "开头为"
        case "endsWith": return "结尾为"
        case "matches": return "正则匹配"
        default: return op
        }
    }
}