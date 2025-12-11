import SwiftUI

struct CreateGistView: View {
    @ObservedObject var viewModel: GistListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var description = ""
    @State private var filename = ""
    @State private var content = ""
    @State private var isPublic = false
    @State private var isCreating = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gist Details")) {
                    TextField("Description (optional)", text: $description)
                    Toggle("Public", isOn: $isPublic)
                }

                Section(header: Text("File")) {
                    TextField("Filename", text: $filename)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        CodeEditor(text: $content)
                            .frame(minHeight: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("New Gist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createGist) {
                        if isCreating {
                            ProgressView()
                        } else {
                            Text("Create")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!isValid || isCreating)
                }
            }
        }
    }

    private var isValid: Bool {
        !filename.isEmpty && !content.isEmpty
    }

    private func createGist() {
        isCreating = true
        errorMessage = nil

        Task {
            do {
                let gist = try await GitHubAPIClient.shared.createGist(
                    description: description.isEmpty ? "Untitled" : description,
                    isPublic: isPublic,
                    files: [filename: content]
                )
                await MainActor.run {
                    viewModel.addGist(gist)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isCreating = false
                }
            }
        }
    }
}
