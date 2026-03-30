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
                onSave: { name, parentId, icon, color, iconUrl in
                    viewModel.createCategory(name: name, parentId: parentId, color: color, icon: icon, iconUrl: iconUrl)
                },
                onDismiss: { viewModel.setCreateOpen(false) }
            )
        }
        .sheet(item: $viewModel.editCategory) { category in
            CategoryEditDialog(
                category: FlatCategory(category: category, indent: 0),
                parentCategories: viewModel.flatCategories.filter { $0.id != category.id },
                onSave: { name, parentId, icon, color, iconUrl in
                    viewModel.updateCategory(categoryId: category.id, name: name, parentId: parentId, color: color, icon: icon, iconUrl: iconUrl)
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

struct CategoryItemView: View {
    let category: FlatCategory
    let onEdit: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            if category.indent > 0 {
                ForEach(0..<category.indent, id: \.self) { _ in
                    Spacer().frame(width: 16)
                }
            }

            CategoryIconView(
                icon: category.category.icon,
                iconUrl: category.category.iconUrl,
                size: 18,
                cornerRadius: 4
            )

            Text(category.category.name)
                .font(.system(size: 14))
                .lineLimit(1)

            Spacer()

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

struct CategoryEditDialog: View {
    let category: FlatCategory?
    let parentCategories: [FlatCategory]
    let onSave: (String, Int?, String?, String?, String?) -> Void
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var parentId: Int?
    @State private var icon: String = ""
    @State private var color: String = "#1677FF"
    @State private var iconUrl: String = ""

    @Environment(\.dismiss) var dismiss

    private let iconOptions = categoryIcons.keys.sorted()

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
                    Picker("预设图标", selection: $icon) {
                        Text("无").tag("")
                        ForEach(iconOptions, id: \.self) { iconName in
                            Text("\(getIconEmoji(iconName)) \(iconName)")
                                .tag(iconName)
                        }
                    }

                    TextField("自定义图标 URL", text: $iconUrl)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    HStack {
                        Text("颜色")
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Color.categoryColors, id: \.self) { preset in
                                    Circle()
                                        .fill(Color(hex: preset))
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: color == preset ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            color = preset
                                        }
                                }
                            }
                        }
                        .frame(width: 200)
                    }

                    Text("预设图标和自定义图标 URL 只能二选一。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(category == nil ? "新建分类" : "编辑分类")
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
                        let trimmedColor = color.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedIconUrl = iconUrl.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(
                            name.trimmingCharacters(in: .whitespacesAndNewlines),
                            parentId,
                            icon.isEmpty ? nil : icon,
                            trimmedColor.isEmpty ? nil : trimmedColor,
                            trimmedIconUrl.isEmpty ? nil : trimmedIconUrl
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if let category {
                name = category.category.name
                parentId = category.category.parentId
                icon = category.category.icon ?? ""
                color = category.category.color ?? "#1677FF"
                iconUrl = category.category.iconUrl ?? ""
            }
        }
        .onChange(of: icon) { newValue in
            if !newValue.isEmpty {
                iconUrl = ""
            }
        }
        .onChange(of: iconUrl) { newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                icon = ""
            }
        }
    }
}
