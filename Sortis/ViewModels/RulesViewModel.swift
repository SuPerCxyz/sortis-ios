//
//  RulesViewModel.swift
//  Sortis
//
//  规则管理视图模型
//

import Foundation

@MainActor
class RulesViewModel: ObservableObject {
    @Published var rules: [Rule] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var error: String?

    @Published var editRule: Rule?
    @Published var actionRule: Rule?

    @Published var categories: [Category] = []

    @Published var currentPage: Int = 1
    @Published var pageSize: Int = 20
    @Published var total: Int = 0
    @Published var totalPages: Int = 0
    @Published var searchQuery: String = ""
    @Published var searchField: String = "all"

    private var allRules: [Rule] = []

    private let ruleService = RuleService()
    private let categoryService = CategoryService()

    init() {
        loadRules()
        loadCategories()
    }

    func loadRules(page: Int = 1, pageSize: Int = 20) {
        Task {
            isLoading = true
            error = nil
            await fetchRules(page: page, pageSize: pageSize)
            isLoading = false
        }
    }

    private func fetchRules(page: Int, pageSize: Int) async {
        do {
            let response = try await ruleService.getRules()
            allRules = response.rules.sorted { ($0.updatedAt ?? $0.createdAt ?? "") > ($1.updatedAt ?? $1.createdAt ?? "") }
            applyFilterAndPagination(page: page, pageSize: pageSize)
        } catch let err {
            error = err.localizedDescription
        }
    }

    private func applyFilterAndPagination(page: Int, pageSize: Int) {
        let keyword = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filtered = allRules.filter { rule in
            guard !keyword.isEmpty else { return true }
            let categoryName = rule.category?.name ?? ""
            let conditionValues = rule.conditions
                .map { "\($0.field) \($0.keyPath ?? "") \($0.op) \($0.value)" }
                .joined(separator: " ")
            let templateValues = "\(rule.titleTemplate ?? "") \(rule.contentTemplate ?? "")"
            let haystack: String
            switch searchField {
            case "name":
                haystack = rule.name
            case "description":
                haystack = rule.description ?? ""
            case "category":
                haystack = categoryName
            case "match_type":
                haystack = rule.matchType
            case "template":
                haystack = templateValues
            case "condition":
                haystack = conditionValues
            default:
                haystack = [rule.name, rule.description ?? "", categoryName, rule.matchType, templateValues, conditionValues]
                    .joined(separator: " ")
            }
            return haystack.lowercased().contains(keyword)
        }
        total = filtered.count
            totalPages = (total > 0) ? (total + pageSize - 1) / pageSize : 0

            let safePage = min(page, max(1, totalPages == 0 ? 1 : totalPages))
            let startIndex = (safePage - 1) * pageSize
            let endIndex = min(startIndex + pageSize, total)

            rules = startIndex < total ? Array(filtered[startIndex..<endIndex]) : []
            currentPage = safePage
    }

    func loadCategories() {
        Task {
            do {
                categories = try await categoryService.getCategoryTree()
            } catch {
                print("Failed to load categories: \(error)")
            }
        }
    }

    func refresh() {
        Task {
            isRefreshing = true
            await fetchRules(page: currentPage, pageSize: pageSize)
            isRefreshing = false
        }
    }

    func changePage(_ page: Int) {
        loadRules(page: page, pageSize: pageSize)
    }

    func changePageSize(_ size: Int) {
        loadRules(page: 1, pageSize: size)
    }

    func setSearchQuery(_ query: String) {
        setSearch(query: query, field: searchField)
    }

    func setSearch(query: String, field: String) {
        searchQuery = query
        searchField = field
        applyFilterAndPagination(page: 1, pageSize: pageSize)
    }

    func setEditRule(_ rule: Rule?) {
        editRule = rule
    }

    func setActionRule(_ rule: Rule?) {
        actionRule = rule
    }

    func createRule(
        name: String,
        description: String?,
        categoryId: Int,
        matchType: String,
        conditions: [RuleConditionDraft],
        isEnabled: Bool,
        titleTemplate: String?,
        contentTemplate: String?
    ) {
        Task {
            let conditionsDict: [String: AnyEncodable] = [
                "match_type": AnyEncodable(matchType),
                "conditions": AnyEncodable(conditions.map { condition in
                    var payload: [String: Any] = [
                        "field": condition.field,
                        "operator": condition.op,
                        "value": condition.value
                    ]
                    if !condition.keyPath.isEmpty {
                        payload["key_path"] = condition.keyPath
                    }
                    return payload
                })
            ]

            do {
                _ = try await ruleService.createRule(
                    name: name,
                    description: description,
                    categoryId: categoryId,
                    conditions: conditionsDict,
                    isEnabled: isEnabled,
                    titleTemplate: titleTemplate,
                    contentTemplate: contentTemplate
                )
                loadRules(page: currentPage, pageSize: pageSize)
                actionRule = nil
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func updateRule(
        ruleId: Int,
        name: String,
        description: String?,
        categoryId: Int?,
        matchType: String,
        conditions: [RuleConditionDraft],
        isEnabled: Bool,
        titleTemplate: String?,
        contentTemplate: String?
    ) {
        Task { [weak self] in
            guard let self = self else { return }
            let conditionsDict: [String: AnyEncodable] = [
                "match_type": AnyEncodable(matchType),
                "conditions": AnyEncodable(conditions.map { condition in
                    var payload: [String: Any] = [
                        "field": condition.field,
                        "operator": condition.op,
                        "value": condition.value
                    ]
                    if !condition.keyPath.isEmpty {
                        payload["key_path"] = condition.keyPath
                    }
                    return payload
                })
            ]

            do {
                let updated = try await self.ruleService.updateRule(
                    ruleId: ruleId,
                    name: name,
                    description: description,
                    categoryId: categoryId,
                    conditions: conditionsDict,
                    isEnabled: isEnabled,
                    titleTemplate: titleTemplate,
                    contentTemplate: contentTemplate
                )
                if let index = self.rules.firstIndex(where: { $0.id == ruleId }) {
                    self.rules[index] = updated
                }
                if let index = self.allRules.firstIndex(where: { $0.id == ruleId }) {
                    self.allRules[index] = updated
                }
                self.editRule = nil
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func toggleRuleEnabled(ruleId: Int) {
        Task {
            do {
                let updated = try await ruleService.toggleRule(ruleId: ruleId)
                if let index = rules.firstIndex(where: { $0.id == ruleId }) {
                    rules[index] = updated
                }
                if let index = allRules.firstIndex(where: { $0.id == ruleId }) {
                    allRules[index] = updated
                }
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func deleteRule(ruleId: Int) {
        Task {
            do {
                _ = try await ruleService.deleteRule(ruleId: ruleId)
                loadRules(page: currentPage, pageSize: pageSize)
                actionRule = nil
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func recategorizeRules() {
        Task {
            do {
                _ = try await ruleService.recategorizeRules()
                loadRules(page: currentPage, pageSize: pageSize)
            } catch let err {
                error = err.localizedDescription
            }
        }
    }
}
