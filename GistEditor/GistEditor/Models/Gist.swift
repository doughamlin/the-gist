import Foundation

struct Gist: Codable, Identifiable {
    let id: String
    let description: String?
    let publicGist: Bool
    let files: [String: GistFile]
    let createdAt: Date
    let updatedAt: Date
    let htmlUrl: String
    let owner: GistOwner?

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case publicGist = "public"
        case files
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case htmlUrl = "html_url"
        case owner
    }

    var fileList: [GistFile] {
        files.values.sorted { $0.filename < $1.filename }
    }

    var title: String {
        description?.isEmpty == false ? description! : fileList.first?.filename ?? "Untitled Gist"
    }
}

struct GistFile: Codable, Identifiable {
    let filename: String
    let type: String?
    let language: String?
    let rawUrl: String?
    let size: Int
    var content: String?

    enum CodingKeys: String, CodingKey {
        case filename
        case type
        case language
        case rawUrl = "raw_url"
        case size
        case content
    }

    var id: String { filename }
}

struct GistOwner: Codable {
    let login: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}

struct CreateGistRequest: Codable {
    let description: String
    let publicGist: Bool
    let files: [String: CreateGistFile]

    enum CodingKeys: String, CodingKey {
        case description
        case publicGist = "public"
        case files
    }
}

struct CreateGistFile: Codable {
    let content: String
}

struct UpdateGistRequest: Codable {
    let description: String?
    let files: [String: UpdateGistFile?]
}

struct UpdateGistFile: Codable {
    let content: String?
    let filename: String?
}
