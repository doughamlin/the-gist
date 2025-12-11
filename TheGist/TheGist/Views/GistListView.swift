import SwiftUI
import Combine

struct GistListView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = GistListViewModel()
    @State private var showingCreateSheet = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading gists...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task {
                                await viewModel.loadGists()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.gists.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No gists yet")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Button("Create Your First Gist") {
                            showingCreateSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(viewModel.gists) { gist in
                            NavigationLink(destination: GistDetailView(gist: gist)) {
                                GistRowView(gist: gist)
                            }
                        }
                        .onDelete(perform: deleteGists)
                    }
                    .refreshable {
                        await viewModel.loadGists()
                    }
                }
            }
            .navigationTitle("My Gists")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let user = authManager.currentUser {
                        HStack {
                            Text(user.login)
                                .font(.subheadline)
                            Button("Sign Out") {
                                authManager.signOut()
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateGistView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadGists()
        }
    }

    private func deleteGists(at offsets: IndexSet) {
        for index in offsets {
            let gist = viewModel.gists[index]
            Task {
                await viewModel.deleteGist(gist)
            }
        }
    }
}

struct GistRowView: View {
    let gist: Gist

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(gist.title)
                .font(.headline)

            HStack {
                Image(systemName: gist.publicGist ? "globe" : "lock")
                    .font(.caption)
                Text("\(gist.files.count) file\(gist.files.count == 1 ? "" : "s")")
                    .font(.caption)
                Spacer()
                Text(gist.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !gist.fileList.isEmpty {
                Text(gist.fileList.map { $0.filename }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

@MainActor
final class GistListViewModel: ObservableObject {
    @Published var gists: [Gist] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = GitHubAPIClient.shared

    func loadGists() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedGists = try await apiClient.fetchGists()
            gists = fetchedGists
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteGist(_ gist: Gist) async {
        do {
            try await apiClient.deleteGist(id: gist.id)
            gists.removeAll { $0.id == gist.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addGist(_ gist: Gist) {
        gists.insert(gist, at: 0)
    }
}
