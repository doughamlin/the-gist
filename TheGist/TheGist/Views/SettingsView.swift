import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    if let user = authManager.currentUser {
                        HStack {
                            Text("Signed in as")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.login)
                                .fontWeight(.medium)
                        }

                        if let name = user.name {
                            HStack {
                                Text("Name")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(name)
                            }
                        }
                    }
                }

                Section {
                    Button(role: .destructive, action: signOut) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func signOut() {
        authManager.signOut()
        dismiss()
    }
}
