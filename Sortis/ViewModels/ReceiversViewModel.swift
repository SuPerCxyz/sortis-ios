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
            receivers = try await receiversTask
            tokens = try await tokensTask
        } catch let err {
            error = err.localizedDescription
        }
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
                } else if type == "http_token", let tokenName, !tokenName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
}
