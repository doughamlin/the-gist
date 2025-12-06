import SwiftUI

struct GistDetailView: View {
    let gist: Gist
    @StateObject private var viewModel: GistDetailViewModel
    @State private var showingSaveAlert = false
    @Environment(\.dismiss) private var dismiss

    init(gist: Gist) {
        self.gist = gist
        _viewModel = StateObject(wrappedValue: GistDetailViewModel(gist: gist))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView("Loading gist content...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                            await viewModel.loadGistContent()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                VStack(spacing: 0) {
                    if viewModel.editableFiles.count > 1 {
                        Picker("File", selection: $viewModel.selectedFileIndex) {
                            ForEach(0..<viewModel.editableFiles.count, id: \.self) { index in
                                Text(viewModel.editableFiles[index].filename)
                                    .tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                    }

                    if !viewModel.editableFiles.isEmpty {
                        let currentFile = viewModel.editableFiles[viewModel.selectedFileIndex]

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(currentFile.filename)
                                    .font(.headline)
                                Spacer()
                                if let language = currentFile.language {
                                    Text(language)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)

                            TextEditor(text: Binding(
                                get: { viewModel.fileContents[currentFile.filename] ?? "" },
                                set: { viewModel.fileContents[currentFile.filename] = $0 }
                            ))
                            .font(.system(.body, design: .monospaced))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.horizontal, 8)
                        }
                    }
                }
            }
        }
        .navigationTitle(gist.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveGist) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(!viewModel.hasChanges || viewModel.isSaving)
            }
        }
        .alert("Gist Saved", isPresented: $showingSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your changes have been saved successfully.")
        }
        .task {
            await viewModel.loadGistContent()
        }
    }

    private func saveGist() {
        Task {
            await viewModel.saveGist()
            if viewModel.errorMessage == nil {
                showingSaveAlert = true
            }
        }
    }
}

@MainActor
class GistDetailViewModel: ObservableObject {
    let gist: Gist
    @Published var editableFiles: [GistFile] = []
    @Published var fileContents: [String: String] = [:]
    @Published var selectedFileIndex = 0
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let apiClient = GitHubAPIClient.shared
    private var originalContents: [String: String] = [:]

    var hasChanges: Bool {
        fileContents != originalContents
    }

    init(gist: Gist) {
        self.gist = gist
    }

    func loadGistContent() async {
        isLoading = true
        errorMessage = nil

        do {
            let fullGist = try await apiClient.fetchGist(id: gist.id)
            editableFiles = fullGist.fileList

            for file in editableFiles {
                if let content = file.content {
                    fileContents[file.filename] = content
                    originalContents[file.filename] = content
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func saveGist() async {
        isSaving = true
        errorMessage = nil

        do {
            let updates = fileContents.filter { key, value in
                originalContents[key] != value
            }

            _ = try await apiClient.updateGist(
                id: gist.id,
                description: gist.description,
                files: updates
            )

            originalContents = fileContents
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}
