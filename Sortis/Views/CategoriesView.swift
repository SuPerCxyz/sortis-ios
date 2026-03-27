//
//  CategoriesView.swift
//  Sortis
//
//  分类管理视图
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.flatCategories.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("暂无分类")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(viewModel.flatCategories, id: \.id) { category in
                            CategoryItemView(
                                category: category,
                                onEdit: { viewModel.setEditCategory(category.category) },
                                onMoveUp: {
                                    if viewModel.canMoveUp(category.category) {
                                        viewModel.moveCategory(categoryId: category.id, moveUp: true)
                                    }
                                },
                                onMoveDown: {
                                    if viewModel.canMoveDown(category.category) {
                                        viewModel.moveCategory(categoryId: category.id, moveUp: false)
                                    }
                                },
                                onDelete: {
                                    viewModel.setActionCategory(category.category)
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
            CategoryEditDialog(
                category: nil,
                parentCategories: viewModel.flatCategories,
                onSave: { name, parentId, icon, color in
                    viewModel.createCategory(name: name, parentId: parentId, color: color, icon: icon, iconUrl: nil)
                },
                onDismiss: { viewModel.setCreateOpen(false) }
            )
        }
        .sheet(item: $viewModel.editCategory) { category in
            CategoryEditDialog(
                category: FlatCategory(category: category, indent: 0),
                parentCategories: viewModel.flatCategories.filter { $0.id != category.id },
                onSave: { name, parentId, icon, color in
                    viewModel.updateCategory(categoryId: category.id, name: name, parentId: parentId, color: color, icon: icon, iconUrl: nil)
                },
                onDismiss: { viewModel.setEditCategory(nil) }
            )
        }
        .alert("确认删除", isPresented: Binding(
            get: { viewModel.actionCategory != nil },
            set: { if !$0 { viewModel.setActionCategory(nil) } }
        )) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let cat = viewModel.actionCategory {
                    viewModel.deleteCategory(categoryId: cat.id)
                }
            }
        } message: {
            Text("确定要删除此分类吗？此操作不可撤销。")
        }
    }
}

// 分类项视图
struct CategoryItemView: View {
    let category: FlatCategory
    let onEdit: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // 缩进
            if category.indent > 0 {
                ForEach(0..<category.indent, id: \.self) { _ in
                    Spacer().frame(width: 16)
                }
            }

            // 图标
            if let color = category.category.color {
                Rectangle()
                    .fill(Color(hex: color))
                    .frame(width: 16, height: 16)
                    .cornerRadius(4)
            } else {
                Rectangle()
                    .fill(Color.sortisPrimary)
                    .frame(width: 16, height: 16)
                    .cornerRadius(4)
            }

            // 名称
            Text(category.category.name)
                .font(.system(size: 14))
                .lineLimit(1)

            Spacer()

            // 操作按钮
            Menu {
                Button(action: onEdit) {
                    Label("编辑", systemImage: "pencil")
                }
                Button(action: onMoveUp) {
                    Label("上移", systemImage: "arrow.up")
                }
                Button(action: onMoveDown) {
                    Label("下移", systemImage: "arrow.down")
                }
                Divider()
                Button(role: .destructive, action: onDelete) {
                    Label("删除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
    }
}

// 分类编辑对话框
struct CategoryEditDialog: View {
    let category: FlatCategory?
    let parentCategories: [FlatCategory]
    let onSave: (String, Int?, String?, String?) -> Void
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var parentId: Int?
    @State private var icon: String = ""
    @State private var color: String = "#1677FF"

    @Environment(\.dismiss) var dismiss

    let defaultColors = [
        "#1677FF", "#52C41A", "#FAAD14", "#F5222D", "#722ED1",
        "#13C2C2", "#EB2F96", "#FA8C16", "#2F54EB", "#0052D9"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("分类名称", text: $name)

                    Picker("父级分类", selection: $parentId) {
                        Text("无（顶级分类）").tag(nil as Int?)
                        ForEach(parentCategories, id: \.id) { cat in
                            Text(String(repeating: "　", count: cat.indent) + cat.category.name)
                                .tag(cat.id as Int?)
                        }
                    }
                }

                Section(header: Text("图标和颜色")) {
                    HStack {
                        Text("图标")
                        Spacer()
                        Text(icon.isEmpty ? "默认" : getIconEmoji(icon))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("颜色")
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(defaultColors, id: \.self) { c in
                                    Circle()
                                        .fill(Color(hex: c))
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: color == c ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            color = c
                                        }
                                }
                            }
                        }
                        .frame(width: 200)
                    }
                }
            }
            .navigationTitle(category == nil ? "新建分类" : "编辑分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        onSave(name, parentId, icon.isEmpty ? nil : icon, color)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .onAppear {
            if let category = category {
                name = category.category.name
                parentId = category.category.parentId
                icon = category.category.icon ?? ""
                color = category.category.color ?? "#1677FF"
            }
        }
    }
}