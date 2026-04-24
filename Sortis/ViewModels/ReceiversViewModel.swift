//
//  ReceiversViewModel.swift
//  Sortis
//
//  接收器管理视图模型
//

import Foundation

@MainActor
class ReceiversViewModel: ObservableObject {
    @Published var receivers: [Receiver] = []
    @Published var tokens: [ApiToken] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var error: String?

    @Published var editReceiver: Receiver?
    @Published var actionReceiver: Receiver?
    @Published var isCreateOpen: Bool = false
    @Published var currentPage: Int = 1
    @Published var pageSize: Int = 20
    @Published var total: Int = 0
    @Published var totalPages: Int = 0
    @Published var searchQuery: String = ""
    @Published var searchField: String = "all"

    private var allReceivers: [Receiver] = []

    private let receiverService = ReceiverService()
    private let tokenService = TokenService()

    var serverUrl: String? {
        UserDefaults.standard.string(forKey: "serverUrl")
    }

    init() {
        loadData()
    }

    func loadData() {
        Task {
            isLoading = true
            error = nil
            await fetchData()
            isLoading = false
        }
    }

    func refresh() {
        Task {
            isRefreshing = true
            error = nil
            await fetchData()
            isRefreshing = false
        }
    }

    private func fetchData() async {
        do {
            async let receiversTask = receiverService.getReceivers()
            async let tokensTask = tokenService.getTokens()
            allReceivers = try await receiversTask
            tokens = try await tokensTask
            applyFilterAndPagination(page: currentPage, pageSize: pageSize)
        } catch let err {
            error = err.localizedDescription
        }
    }

    private func applyFilterAndPagination(page: Int, pageSize: Int) {
        let keyword = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filtered = allReceivers
            .filter { receiver in
                guard !keyword.isEmpty else { return true }
                let boundTokenNames = tokens
                    .filter { token in
                        token.isActive && ((token.receiverIds ?? []).contains(receiver.id) || token.receiverId == receiver.id)
                    }
                    .map(\.name)
                    .joined(separator: " ")
                let displayStatus = receiver.errorMessage?.isEmpty == false ? "error" : receiver.status
                let statusLabel = receiverStatusDisplayName(displayStatus)
                let typeLabel = receiverTypeDisplayName(receiver.type)
                let searchableText: String
                switch searchField {
                case "name":
                    searchableText = receiver.name
                case "type":
                    searchableText = "\(receiver.type) \(typeLabel)"
                case "status":
                    searchableText = "\(receiver.status) \(displayStatus) \(statusLabel)"
                case "token":
                    searchableText = boundTokenNames
                default:
                    searchableText = [
                        receiver.name,
                        receiver.type,
                        typeLabel,
                        receiver.status,
                        displayStatus,
                        statusLabel,
                        boundTokenNames
                    ].joined(separator: " ")
                }
                return searchableText.lowercased().contains(keyword)
            }
            .sorted { ($0.updatedAt ?? $0.createdAt ?? "") > ($1.updatedAt ?? $1.createdAt ?? "") }

        total = filtered.count
        totalPages = total > 0 ? (total + pageSize - 1) / pageSize : 0
        let safePage = min(page, max(1, totalPages == 0 ? 1 : totalPages))
        let startIndex = (safePage - 1) * pageSize
        let endIndex = min(startIndex + pageSize, total)
        receivers = startIndex < total ? Array(filtered[startIndex..<endIndex]) : []
        currentPage = safePage
    }

    func setEditReceiver(_ receiver: Receiver?) {
        editReceiver = receiver
    }

    func setActionReceiver(_ receiver: Receiver?) {
        actionReceiver = receiver
    }

    func setCreateOpen(_ open: Bool) {
        isCreateOpen = open
    }

    func changePage(_ page: Int) {
        applyFilterAndPagination(page: page, pageSize: pageSize)
    }

    func setSearchQuery(_ query: String) {
        setSearch(query: query, field: searchField)
    }

    func setSearch(query: String, field: String) {
        searchQuery = query
        searchField = field
        applyFilterAndPagination(page: 1, pageSize: pageSize)
    }

    func createReceiver(
        name: String,
        type: String,
        syncInterval: Int,
        config: [String: AnyEncodable]?,
        selectedTokenId: Int?,
        tokenName: String?,
        tokenDescription: String?,
        tokenExpiresInDays: Int?
    ) {
        Task {
            do {
                let receiver = try await receiverService.createReceiver(
                    name: name,
                    type: type,
                    config: config,
                    syncInterval: type == "http_token" || type == "websocket" ? nil : syncInterval
                )

                if (type == "http_token" || type == "websocket"), let selectedTokenId {
                    _ = try await tokenService.bindTokenToReceiver(tokenId: selectedTokenId, receiverId: receiver.id)
                } else if (type == "http_token" || type == "websocket"), let tokenName, !tokenName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    _ = try await tokenService.createToken(
                        name: tokenName,
                        receiverIds: [receiver.id],
                        expiresInDays: tokenExpiresInDays,
                        description: tokenDescription
                    )
                }

                isCreateOpen = false
                await fetchData()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func updateReceiver(
        receiverId: Int,
        name: String,
        syncInterval: Int,
        config: [String: AnyEncodable]?,
        selectedTokenId: Int?
    ) {
        Task {
            do {
                let updatedReceiver = try await receiverService.updateReceiver(
                    receiverId: receiverId,
                    name: name,
                    config: config,
                    syncInterval: editReceiver?.type == "http_token" || editReceiver?.type == "websocket" ? nil : syncInterval
                )

                if updatedReceiver.type == "http_token" || updatedReceiver.type == "websocket" {
                    if let selectedTokenId {
                        _ = try await tokenService.bindTokenToReceiver(tokenId: selectedTokenId, receiverId: receiverId)
                    } else if let currentToken = boundToken(for: updatedReceiver) {
                        let remainingReceiverIds = (currentToken.receiverIds ?? (currentToken.receiverId.map { [$0] } ?? []))
                            .filter { $0 != receiverId }
                        _ = try await tokenService.bindTokenToReceivers(tokenId: currentToken.id, receiverIds: remainingReceiverIds)
                    }
                }

                editReceiver = nil
                await fetchData()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func syncReceiver(receiverId: Int) {
        Task {
            do {
                _ = try await receiverService.syncReceiver(receiverId: receiverId)
                await fetchData()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func toggleReceiver(receiverId: Int) {
        Task {
            do {
                let updated = try await receiverService.toggleReceiver(receiverId: receiverId)
                if let index = receivers.firstIndex(where: { $0.id == receiverId }) {
                    receivers[index] = updated
                }
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func deleteReceiver(receiverId: Int) {
        Task {
            do {
                _ = try await receiverService.deleteReceiver(receiverId: receiverId)
                actionReceiver = nil
                await fetchData()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func validateReceiver(type: String, config: [String: AnyEncodable]) async -> Bool {
        do {
            _ = try await receiverService.validateReceiver(type: type, config: config)
            return true
        } catch {
            return false
        }
    }

    func boundToken(for receiver: Receiver) -> ApiToken? {
        tokens.first {
            $0.isActive && (($0.receiverIds ?? []).contains(receiver.id) || $0.receiverId == receiver.id)
        }
    }

    private func receiverTypeDisplayName(_ type: String) -> String {
        switch type {
        case "email": return "邮件"
        case "telegram": return "Telegram"
        case "http_token": return "Webhook"
        case "rss": return "RSS"
        case "websocket": return "WebSocket"
        default: return type
        }
    }

    private func receiverStatusDisplayName(_ status: String) -> String {
        switch status {
        case "active": return "运行中"
        case "paused": return "已暂停"
        case "inactive": return "已停止"
        case "error": return "错误"
        default: return status
        }
    }
}
