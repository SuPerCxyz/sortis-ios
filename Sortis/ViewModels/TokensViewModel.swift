//
//  TokensViewModel.swift
//  Sortis
//
//  Token 管理视图模型
//

import Foundation

@MainActor
class TokensViewModel: ObservableObject {
    @Published var tokens: [ApiToken] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var error: String?

    @Published var editToken: ApiToken?
    @Published var actionToken: ApiToken?
    @Published var createdToken: String?
    @Published var isCreateOpen: Bool = false
    @Published var receivers: [Receiver] = []

    @Published var currentPage: Int = 1
    @Published var pageSize: Int = 20
    @Published var total: Int = 0
    @Published var totalPages: Int = 0

    private var allTokens: [ApiToken] = []

    private let tokenService = TokenService()
    private let receiverService = ReceiverService()

    init() {
        loadTokens()
        loadReceivers()
    }

    func loadTokens(page: Int = 1, pageSize: Int = 20) {
        Task {
            isLoading = true
            error = nil
            await fetchTokens(page: page, pageSize: pageSize)
            isLoading = false
        }
    }

    private func fetchTokens(page: Int, pageSize: Int) async {
        do {
            let tokenList = try await tokenService.getTokens()
            allTokens = tokenList.sorted { ($0.lastUsedAt ?? $0.createdAt ?? "") > ($1.lastUsedAt ?? $1.createdAt ?? "") }
            total = allTokens.count
            totalPages = (total > 0) ? (total + pageSize - 1) / pageSize : 0

            let startIndex = (page - 1) * pageSize
            let endIndex = min(startIndex + pageSize, total)

            tokens = startIndex < total ? Array(allTokens[startIndex..<endIndex]) : []
            currentPage = page
        } catch let err {
            error = err.localizedDescription
        }
    }

    func loadReceivers() {
        Task {
            do {
                receivers = try await receiverService.getReceivers()
            } catch {
                print("Failed to load receivers: \(error)")
            }
        }
    }

    func refresh() {
        Task {
            isRefreshing = true
            await fetchTokens(page: currentPage, pageSize: pageSize)
            isRefreshing = false
        }
    }

    func changePage(_ page: Int) {
        loadTokens(page: page, pageSize: pageSize)
    }

    func changePageSize(_ size: Int) {
        loadTokens(page: 1, pageSize: size)
    }

    func setEditToken(_ token: ApiToken?) {
        editToken = token
    }

    func setActionToken(_ token: ApiToken?) {
        actionToken = token
    }

    func setCreateOpen(_ open: Bool) {
        isCreateOpen = open
        if !open {
            createdToken = nil
        }
    }

    func createToken(name: String, receiverIds: [Int]?, expiresInDays: Int?) {
        Task {
            do {
                let response = try await tokenService.createToken(name: name, receiverIds: receiverIds, expiresInDays: expiresInDays)
                createdToken = response.token
                isCreateOpen = true
                loadTokens(page: currentPage, pageSize: pageSize)
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func updateToken(tokenId: Int, name: String) {
        Task {
            do {
                let updated = try await tokenService.updateToken(tokenId: tokenId, name: name)
                if let index = tokens.firstIndex(where: { $0.id == tokenId }) {
                    tokens[index] = updated
                }
                if let index = allTokens.firstIndex(where: { $0.id == tokenId }) {
                    allTokens[index] = updated
                }
                editToken = nil
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func revokeOrActivate(tokenId: Int, isActive: Bool) {
        Task {
            do {
                if isActive {
                    _ = try await tokenService.revokeToken(tokenId: tokenId)
                } else {
                    _ = try await tokenService.activateToken(tokenId: tokenId)
                }
                loadTokens(page: currentPage, pageSize: pageSize)
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func deleteToken(tokenId: Int) {
        Task {
            do {
                _ = try await tokenService.deleteToken(tokenId: tokenId)
                loadTokens(page: currentPage, pageSize: pageSize)
                actionToken = nil
            } catch let err {
                error = err.localizedDescription
            }
        }
    }
}