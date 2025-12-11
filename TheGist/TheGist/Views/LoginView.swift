import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var token = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)

                Text("The Gist")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("GitHub Gist Editor")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Text("Enter your GitHub Personal Access Token")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 20)

                SecureField("GitHub Token", text: $token)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Button(action: signIn) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(token.isEmpty || isLoading)
                .padding(.horizontal)

                Link("Create a Personal Access Token", destination: URL(string: "https://github.com/settings/tokens/new?scopes=gist")!)
                    .font(.caption)
                    .padding(.top, 10)

                Text("Required scope: gist")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Login")
        }
    }

    private func signIn() {
        isLoading = true
        Task {
            await authManager.saveToken(token)
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
