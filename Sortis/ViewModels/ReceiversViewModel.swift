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
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var error: String?

    @Published var editReceiver: Receiver?
    @Published var actionReceiver: Receiver?
    @Published var isCreateOpen: Bool = false

    private let receiverService = ReceiverService()

    init() {
        loadReceivers()
    }

    func loadReceivers() {
        Task {
            isLoading = true
            error = nil
            do {
                receivers = try await receiverService.getReceivers()
            } catch let err {
                error = err.localizedDescription
            }
            isLoading = false
        }
    }

    func refresh() {
        Task {
            isRefreshing = true
            error = nil
            do {
                receivers = try await receiverService.getReceivers()
            } catch let err {
                error = err.localizedDescription
            }
            isRefreshing = false
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

    func createReceiver(name: String, type: String, config: [String: AnyEncodable]?, syncInterval: Int?) {
        Task {
            do {
                _ = try await receiverService.createReceiver(name: name, type: type, config: config, syncInterval: syncInterval)
                isCreateOpen = false
                loadReceivers()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func updateReceiver(receiverId: Int, name: String, config: [String: AnyEncodable]?, syncInterval: Int?) {
        Task {
            do {
                _ = try await receiverService.updateReceiver(receiverId: receiverId, name: name, config: config, syncInterval: syncInterval)
                editReceiver = nil
                loadReceivers()
            } catch let err {
                error = err.localizedDescription
            }
        }
    }

    func syncReceiver(receiverId: Int) {
        Task {
            do {
                _ = try await receiverService.syncReceiver(receiverId: receiverId)
                loadReceivers()
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
                loadReceivers()
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
}