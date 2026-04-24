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
        Group {
            if let selectedCategory = viewModel.selectedCategory {
                CategoryMessagesScreen(viewModel: viewModel, selectedCategory: selectedCategory)
            } else {
                CategoryListScreen(viewModel: viewModel)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.setCreateOpen(true) }) {
                    SortisCreateIcon(size: 18)
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
                parentCategories: viewModel.moveParentCandidates(for: category),
                onSave: { name, parentId, icon, color, iconUrl in
                    viewModel.updateCategory(categoryId: category.id, name: name, parentId: parentId, color: color, icon: icon, iconUrl: iconUrl)
                },
                onDismiss: { viewModel.setEditCategory(nil) }
            )
        }
        .sheet(item: $viewModel.moveCategoryTarget) { category in
            CategoryMoveDialog(
                category: category,
                parentCategories: viewModel.moveParentCandidates(for: category),
                onMove: { parentId in
                    viewModel.moveCategory(categoryId: category.id, toParentId: parentId)
                },
                onDismiss: { viewModel.setMoveCategoryTarget(nil) }
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

struct CategoryListScreen: View {
    @ObservedObject var viewModel: CategoriesViewModel

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
                                onOpen: { viewModel.selectCategory(category.category) },
                                onEdit: { viewModel.setEditCategory(category.category) },
                                onMoveToParent: { viewModel.setMoveCategoryTarget(category.category) },
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
    }
}

struct CategoryMessagesScreen: View {
    @ObservedObject var viewModel: CategoriesViewModel
    let selectedCategory: Category

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { viewModel.clearSelectedCategory() }) {
                    Image(systemName: "arrow.left")
                }
                Text(selectedCategory.name)
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            HStack {
                PaginationControl(
                    currentPage: viewModel.currentPage,
                    totalPages: viewModel.totalPages,
                    onPageChange: { viewModel.changePage($0) }
                )

                Spacer()

                TimeRangePicker(timeRange: $viewModel.timeRange) {
                    viewModel.setTimeRange($0)
                }
            }
            .padding(.horizontal)

            HStack(spacing: 8) {
                Picker(selection: Binding(
                    get: { viewModel.messageStatusFilter },
                    set: { viewModel.setMessageStatusFilter($0) }
                )) {
                    Text("全部").tag("all")
                    Text("未读").tag("unread")
                    Text("已读").tag("read")
                    Text("星标").tag("starred")
                    Text("未分类").tag("uncategorized")
                } label: {
                    HStack(spacing: 6) {
                        SortisMessageFilterIcon(size: 14, color: .secondary)
                        Text("状态")
                    }
                }
                .pickerStyle(.menu)

                HStack(spacing: 8) {
                    Menu {
                        ForEach(messageSearchFieldOptions) { option in
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
                            Text(searchFieldLabel(for: viewModel.searchField, options: messageSearchFieldOptions))
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
                        .sortisCenteredPlaceholder("搜索信息", isEmpty: viewModel.searchQuery.isEmpty)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit {
                            viewModel.setSearch(query: viewModel.searchQuery, field: viewModel.searchField)
                        }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.messages.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("该分类暂无信息")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            MessageEntityCard(message: message) {
                                viewModel.selectMessage(message)
                            }
                            .onLongPressGesture {
                                viewModel.setActionMessage(message)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .refreshable {
                    viewModel.refresh()
                }
            }
        }
        .sheet(item: $viewModel.selectedMessage) { message in
            MessageEntityDetailSheet(
                message: message,
                onToggleRead: { viewModel.toggleRead(messageId: message.id) },
                onToggleStar: { viewModel.toggleStar(messageId: message.id) }
            ) {
                viewModel.selectMessage(nil)
            }
        }
        .sheet(item: $viewModel.actionMessage) { message in
            MessageActionSheet(
                message: message,
                categories: viewModel.getAllFlatCategories(),
                onToggleRead: { viewModel.toggleRead(messageId: message.id) },
                onToggleStar: { viewModel.toggleStar(messageId: message.id) },
                onMove: { viewModel.moveMessage(messageId: message.id, categoryId: $0) },
                onDelete: { deleteRemote in
                    viewModel.deleteMessage(messageId: message.id, deleteRemote: deleteRemote)
                },
                onDismiss: { viewModel.setActionMessage(nil) }
            )
        }
    }
}

struct CategoryItemView: View {
    let category: FlatCategory
    let onOpen: () -> Void
    let onEdit: () -> Void
    let onMoveToParent: () -> Void
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
                .onTapGesture(perform: onOpen)

            Spacer()

            Menu {
                Button(action: onOpen) {
                    Label("查看信息", systemImage: "tray.full")
                }
                Button(action: onEdit) {
                    Label("编辑", systemImage: "pencil")
                }
                Button(action: onMoveToParent) {
                    Label("移动分类", systemImage: "arrowshape.turn.up.right")
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

struct CategoryMoveDialog: View {
    let category: Category
    let parentCategories: [FlatCategory]
    let onMove: (Int?) -> Void
    let onDismiss: () -> Void

    @State private var parentId: Int?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Picker("目标父分类", selection: $parentId) {
                    Text("无（顶级分类）").tag(nil as Int?)
                    ForEach(parentCategories, id: \.id) { cat in
                        Text(String(repeating: "　", count: cat.indent) + cat.category.name)
                            .tag(cat.id as Int?)
                    }
                }
            }
            .navigationTitle("移动分类")
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
                        onMove(parentId)
                        dismiss()
                    }
                }
            }
            .onAppear {
                parentId = category.parentId
            }
        }
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
    @State private var randomColorPresets: [String] = Color.generateVividCategoryColors(count: 10)

    @Environment(\.dismiss) var dismiss

    private let iconOptions = CategoryIconPickerModel.options

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("", text: $name)
                        .sortisCenteredPlaceholder("分类名称", isEmpty: name.isEmpty)

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
                        ForEach(iconOptions, id: \.value) { option in
                            Label {
                                Text(option.label)
                            } icon: {
                                CategoryIconView(
                                    icon: option.value,
                                    iconUrl: nil,
                                    size: 16,
                                    cornerRadius: 4
                                )
                            }
                            .tag(option.value)
                        }
                    }

                    TextField("", text: $iconUrl)
                        .sortisCenteredPlaceholder("自定义图标 URL", isEmpty: iconUrl.isEmpty)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("颜色")
                            Spacer()
                            Button {
                                let next = Color.generateVividCategoryColors(count: 10)
                                randomColorPresets = next
                                if !next.contains(where: { $0.caseInsensitiveCompare(color) == .orderedSame }) {
                                    color = next.first ?? color
                                }
                            } label: {
                                Label("换一组", systemImage: "arrow.clockwise")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: color))
                                .frame(width: 28, height: 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                )
                            Text(color.uppercased())
                                .font(.caption.monospacedDigit())
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(randomColorPresets, id: \.self) { preset in
                                    Circle()
                                        .fill(Color(hex: preset))
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: color.caseInsensitiveCompare(preset) == .orderedSame ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            color = preset.uppercased()
                                        }
                                }
                            }
                        }
                        .frame(width: 220)
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
                icon = CategoryIconPickerModel.canonicalValue(for: category.category.icon)
                randomColorPresets = Color.generateVividCategoryColors(count: 10)
                color = (category.category.color ?? (randomColorPresets.first ?? "#1677FF")).uppercased()
                iconUrl = category.category.iconUrl ?? ""
            } else {
                randomColorPresets = Color.generateVividCategoryColors(count: 10)
                color = (randomColorPresets.first ?? "#1677FF").uppercased()
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
