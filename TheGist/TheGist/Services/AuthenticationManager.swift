import Foundation
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: GitHubUser?
    @Published var errorMessage: String?

    private let tokenKey = "github_token"
    private let apiClient = GitHubAPIClient.shared

    init() {
        loadToken()
    }

    func loadToken() {
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            apiClient.setToken(token)
            Task {
                await verifyToken()
            }
        }
    }

    func saveToken(_ token: String) async {
        UserDefaults.standard.set(token, forKey: tokenKey)
        apiClient.setToken(token)
        await verifyToken()
    }

    func verifyToken() async {
        do {
            let user = try await apiClient.verifyToken()
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        isAuthenticated = false
        currentUser = nil
    }
}
