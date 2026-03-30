//
//  APIClient.swift
//  Sortis
//
//  API 客户端
//

import Foundation

class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let tokenManager = TokenManager.shared

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // 获取服务器地址
    private var serverUrl: String {
        UserDefaults.standard.string(forKey: "serverUrl") ?? ""
    }

    // 构建完整 URL（公共方法）
    func makeURL(path: String) -> URL? {
        let baseUrl = serverUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let fullPath = "\(baseUrl)\(path)"
        return URL(string: fullPath)
    }

    // 构建完整 URL（私有方法）
    private func buildURL(path: String) -> URL? {
        return makeURL(path: path)
    }

    // 构建请求
    private func buildRequest(url: URL, method: String, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 添加认证 Token
        if let token = tokenManager.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    // GET 请求
    func get<T: Decodable>(path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        guard var urlComponents = URLComponents(url: buildURL(path: path)!, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        let request = buildRequest(url: url, method: "GET")
        return try await performRequest(request)
    }

    // POST 请求
    func post<T: Decodable, B: Encodable>(path: String, body: B? = nil) async throws -> T {
        guard let url = buildURL(path: path) else {
            throw APIError.invalidURL
        }

        var bodyData: Data?
        if let body = body {
            bodyData = try JSONEncoder().encode(body)
        }

        let request = buildRequest(url: url, method: "POST", body: bodyData)
        return try await performRequest(request)
    }

    // POST 请求（无请求体）
    func postWithoutBody<T: Decodable>(path: String) async throws -> T {
        guard let url = buildURL(path: path) else {
            throw APIError.invalidURL
        }

        let request = buildRequest(url: url, method: "POST")
        return try await performRequest(request)
    }

    // POST 请求（无响应体）
    func postEmpty(path: String) async throws -> Bool {
        guard let url = buildURL(path: path) else {
            throw APIError.invalidURL
        }

        let request = buildRequest(url: url, method: "POST")
        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        return httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
    }

    // POST 请求（表单数据）
    func postForm<T: Decodable>(path: String, formData: [String: String]) async throws -> T {
        guard let url = buildURL(path: path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        if let token = tokenManager.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let formString = formData.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = formString.data(using: .utf8)

        return try await performRequest(request)
    }

    // PUT 请求
    func put<T: Decodable, B: Encodable>(path: String, body: B) async throws -> T {
        guard let url = buildURL(path: path) else {
            throw APIError.invalidURL
        }

        let bodyData = try JSONEncoder().encode(body)
        let request = buildRequest(url: url, method: "PUT", body: bodyData)
        return try await performRequest(request)
    }

    // DELETE 请求
    func delete(path: String) async throws -> Bool {
        guard let url = buildURL(path: path) else {
            throw APIError.invalidURL
        }

        let request = buildRequest(url: url, method: "DELETE")
        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        return httpResponse.statusCode == 200 || httpResponse.statusCode == 204
    }

    // 执行请求
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

// API 错误
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "无效的响应"
        case .serverError(let statusCode, let message):
            return "服务器错误 (\(statusCode)): \(message)"
        case .decodingError(let error):
            return "解码错误: \(error.localizedDescription)"
        }
    }
}
