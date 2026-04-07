import Foundation

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case unauthorized
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "無効なURLです"
        case .noData: return "データがありません"
        case .decodingError: return "データの読み込みに失敗しました"
        case .serverError(let code): return "サーバーエラー (\(code))"
        case .unauthorized: return "認証が必要です"
        case .networkError: return "通信エラーが発生しました"
        }
    }
}

// MARK: - API Client
actor APIClient {
    static let shared = APIClient()

    private let baseURL: String
    private let session = URLSession.shared

    init() {
        self.baseURL = APIConfig.resolveBaseURL()
    }

    private func makeRequest(
        path: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> Data {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            if !(200...299).contains(httpResponse.statusCode) {
                throw APIError.serverError(httpResponse.statusCode)
            }
            return data
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    func get<T: Decodable>(path: String) async throws -> T {
        let data = try await makeRequest(path: path)
        do {
            return try decoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }

    func post<T: Decodable, B: Encodable>(path: String, body: B) async throws -> T {
        let bodyData = try encoder().encode(body)
        let data = try await makeRequest(path: path, method: "POST", body: bodyData)
        do {
            return try decoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }

    func delete(path: String) async throws {
        _ = try await makeRequest(path: path, method: "DELETE")
    }

    func patch<T: Decodable, B: Encodable>(path: String, body: B) async throws -> T {
        let bodyData = try encoder().encode(body)
        let data = try await makeRequest(path: path, method: "PATCH", body: bodyData)
        do {
            return try decoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }

    // MARK: - Private Helpers (within actor isolation)
    private func decoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }

    private func encoder() -> JSONEncoder {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        e.dateEncodingStrategy = .iso8601
        return e
    }
}
