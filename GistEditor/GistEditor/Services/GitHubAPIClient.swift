import Foundation

class GitHubAPIClient {
    static let shared = GitHubAPIClient()
    private let baseURL = "https://api.github.com"

    private var token: String?

    func setToken(_ token: String) {
        self.token = token
    }

    private func createRequest(url: URL, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    // MARK: - Fetch Gists

    func fetchGists() async throws -> [Gist] {
        guard let url = URL(string: "\(baseURL)/gists") else {
            throw APIError.invalidURL
        }

        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Gist].self, from: data)
    }

    // MARK: - Fetch Single Gist

    func fetchGist(id: String) async throws -> Gist {
        guard let url = URL(string: "\(baseURL)/gists/\(id)") else {
            throw APIError.invalidURL
        }

        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Gist.self, from: data)
    }

    // MARK: - Create Gist

    func createGist(description: String, isPublic: Bool, files: [String: String]) async throws -> Gist {
        guard let url = URL(string: "\(baseURL)/gists") else {
            throw APIError.invalidURL
        }

        let gistFiles = files.mapValues { CreateGistFile(content: $0) }
        let createRequest = CreateGistRequest(
            description: description,
            publicGist: isPublic,
            files: gistFiles
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try encoder.encode(createRequest)

        let request = createRequest(url: url, method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 201 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Gist.self, from: data)
    }

    // MARK: - Update Gist

    func updateGist(id: String, description: String?, files: [String: String?]) async throws -> Gist {
        guard let url = URL(string: "\(baseURL)/gists/\(id)") else {
            throw APIError.invalidURL
        }

        let updateFiles = files.mapValues { content -> UpdateGistFile? in
            guard let content = content else { return nil }
            return UpdateGistFile(content: content, filename: nil)
        }

        let updateRequest = UpdateGistRequest(
            description: description,
            files: updateFiles
        )

        let encoder = JSONEncoder()
        let body = try encoder.encode(updateRequest)

        let request = createRequest(url: url, method: "PATCH", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Gist.self, from: data)
    }

    // MARK: - Delete Gist

    func deleteGist(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/gists/\(id)") else {
            throw APIError.invalidURL
        }

        let request = createRequest(url: url, method: "DELETE")
        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 204 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    // MARK: - Verify Token

    func verifyToken() async throws -> GitHubUser {
        guard let url = URL(string: "\(baseURL)/user") else {
            throw APIError.invalidURL
        }

        let request = createRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(GitHubUser.self, from: data)
    }
}

// MARK: - Error Types

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .unauthorized:
            return "Unauthorized. Please check your GitHub token."
        }
    }
}

struct GitHubUser: Codable {
    let login: String
    let name: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case login
        case name
        case avatarUrl = "avatar_url"
    }
}
