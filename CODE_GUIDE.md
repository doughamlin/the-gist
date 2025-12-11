# The Gist - Code Guide for iOS Beginners

This guide explains the purpose and functionality of each file in The Gist app, designed for developers new to iOS and Swift development.

## 📁 Project Structure Overview

```
TheGist/
├── TheGist/                          # Main app folder
│   ├── TheGistApp.swift              # App entry point
│   ├── Assets.xcassets/              # Images, icons, colors
│   ├── Models/                       # Data structures
│   ├── Services/                     # Business logic & API
│   └── Views/                        # User interface
└── TheGist.xcodeproj/                # Xcode project file
```

---

## 🎯 Core App File

### `TheGistApp.swift` - The App Entry Point

**What it does**: This is the starting point of the entire app. When you launch The Gist, iOS looks for the `@main` attribute and runs this file first.

**Key concepts**:
- [`@main`](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/#main): Tells iOS "start the app here"
- [`App` protocol](https://developer.apple.com/documentation/swiftui/app): Required for all SwiftUI apps
- [`Scene`](https://developer.apple.com/documentation/swiftui/scene): Represents a window or screen in your app
- [`WindowGroup`](https://developer.apple.com/documentation/swiftui/windowgroup): Creates a window for iPhone/iPad
- [`@StateObject`](https://developer.apple.com/documentation/swiftui/stateobject): Creates and owns an object that survives app lifecycle

**Code breakdown**:
```swift
@main  // ← iOS starts here
struct TheGistApp: App {
    // Create the authentication manager once
    @StateObject private var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()  // ← The first view users see
                .environmentObject(authManager)  // ← Share auth with all views
        }
    }
}
```

**Why it matters**: This file sets up the entire app and makes the authentication manager available to all views via `@EnvironmentObject`.

---

## 📊 Models (Data Structures)

### `Models/Gist.swift` - Data Models

**What it does**: Defines the structure of data received from GitHub's API and sent back to it.

**Key concepts**:
- [`struct`](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/classesandstructures/): A data type that groups related properties together
- [`Codable`](https://developer.apple.com/documentation/swift/codable): Allows converting between Swift objects and JSON
- [`Identifiable`](https://developer.apple.com/documentation/swift/identifiable): Required for SwiftUI lists (needs unique `id`)
- [`enum CodingKeys`](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types): Maps JSON field names to Swift property names

**Main structures**:

#### 1. `Gist` - Represents a GitHub Gist
```swift
struct Gist: Codable, Identifiable {
    let id: String                    // Unique identifier
    let description: String?          // Optional description
    let publicGist: Bool              // Public or private?
    let files: [String: GistFile]     // Dictionary of files
    let createdAt: Date               // When created
    let updatedAt: Date               // Last modified
    let htmlUrl: String               // Web URL
    let owner: GistOwner?             // Who owns it
}
```

**Why dictionary for files?**: GitHub's API returns files as a JSON object where keys are filenames:
```json
{
  "files": {
    "hello.swift": { "content": "..." },
    "readme.md": { "content": "..." }
  }
}
```

#### 2. `GistFile` - Represents a single file in a gist
```swift
struct GistFile: Codable, Identifiable {
    let filename: String          // e.g., "script.js"
    let type: String?             // MIME type
    let language: String?         // e.g., "JavaScript"
    let rawUrl: String?           // Direct download URL
    let size: Int                 // File size in bytes
    var content: String?          // The actual code/text
}
```

#### 3. `GistOwner` - Who created the gist
```swift
struct GistOwner: Codable {
    let login: String             // GitHub username
    let avatarUrl: String?        // Profile picture URL
}
```

#### 4. Request/Response Types
These are used when creating or updating gists:

- `CreateGistRequest`: What we send to GitHub when creating
- `CreateGistFile`: A file within a create request
- `UpdateGistRequest`: What we send when updating
- `UpdateGistFile`: A file within an update request

**Why separate request types?**: The API expects different formats for create vs. update operations.

**Computed properties**:
```swift
var fileList: [GistFile] {
    files.values.sorted { $0.filename < $1.filename }
}
```
This converts the dictionary to a sorted array for easier display in lists.

---

## 🔧 Services (Business Logic)

### `Services/GitHubAPIClient.swift` - API Communication

**What it does**: Handles all communication with GitHub's REST API. It's the "bridge" between your app and GitHub's servers.

**Key concepts**:
- [`class`](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/classesandstructures/): Reference type (vs struct's value type)
- [`static let shared`](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/#Type-Properties): Singleton pattern - only one instance exists
- [`async/await`](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/): Modern way to handle asynchronous operations
- [`throws`](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling/): Can produce errors that must be handled
- [`URLSession`](https://developer.apple.com/documentation/foundation/urlsession): Apple's networking framework

**Architecture pattern**: This is a **Service Layer** - it separates networking logic from UI code.

**Main methods**:

#### 1. `fetchGists()` - Get all user's gists
```swift
func fetchGists() async throws -> [Gist] {
    // 1. Create URL
    // 2. Create request with auth headers
    // 3. Send request and wait for response
    // 4. Check status code
    // 5. Decode JSON to [Gist]
    // 6. Return results
}
```

#### 2. `fetchGist(id:)` - Get one specific gist with full content
```swift
func fetchGist(id: String) async throws -> Gist
```

#### 3. `createGist(...)` - Create a new gist
```swift
func createGist(
    description: String,
    isPublic: Bool,
    files: [String: String]  // filename: content
) async throws -> Gist
```

#### 4. `updateGist(...)` - Modify existing gist
```swift
func updateGist(
    id: String,
    description: String?,
    files: [String: String?]  // nil means delete file
) async throws -> Gist
```

#### 5. `deleteGist(id:)` - Remove a gist
```swift
func deleteGist(id: String) async throws
```

#### 6. `verifyToken()` - Check if auth token is valid
```swift
func verifyToken() async throws -> GitHubUser
```

**How authentication works**:
```swift
private func createRequest(url: URL, method: String, body: Data?) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method

    if let token = token {
        // This header authenticates with GitHub
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    return request
}
```

**Error handling**:
```swift
enum APIError: LocalizedError {
    case invalidURL          // URL couldn't be formed
    case invalidResponse     // Server sent bad data
    case httpError(Int)      // HTTP status code error
    case unauthorized        // Bad/expired token
}
```

**Why singleton pattern?**:
```swift
static let shared = GitHubAPIClient()
```
This ensures only one instance exists, which is good for:
- Sharing the auth token
- Connection pooling
- Consistent state

---

### `Services/AuthenticationManager.swift` - Authentication State

**What it does**: Manages the user's login state and GitHub token throughout the app.

**Key concepts**:
- [`ObservableObject`](https://developer.apple.com/documentation/combine/observableobject): Allows SwiftUI views to watch for changes
- [`@Published`](https://developer.apple.com/documentation/combine/published): Automatically notifies views when value changes
- [`UserDefaults`](https://developer.apple.com/documentation/foundation/userdefaults): Simple key-value storage (like browser localStorage)
- [`Task`](https://developer.apple.com/documentation/swift/task): Runs async code

**Architecture pattern**: This is a **State Manager** using the MVVM pattern.

**Properties**:
```swift
@Published var isAuthenticated = false     // Logged in?
@Published var currentUser: GitHubUser?    // User info
@Published var errorMessage: String?       // Error to display
```

When any of these change, SwiftUI views automatically re-render.

**Lifecycle**:
```swift
init() {
    loadToken()  // Check for saved token on startup
}
```

**Main methods**:

#### 1. `loadToken()` - Check for saved token
```swift
func loadToken() {
    if let token = UserDefaults.standard.string(forKey: tokenKey) {
        apiClient.setToken(token)
        Task { await verifyToken() }  // Verify it's still valid
    }
}
```

#### 2. `saveToken(_:)` - Save new token
```swift
func saveToken(_ token: String) async {
    UserDefaults.standard.set(token, forKey: tokenKey)  // Save locally
    apiClient.setToken(token)                           // Use for API calls
    await verifyToken()                                 // Verify it works
}
```

#### 3. `verifyToken()` - Check if token is valid
```swift
func verifyToken() async {
    do {
        let user = try await apiClient.verifyToken()
        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
            self.errorMessage = nil
        }
    } catch {
        // Token is invalid
        await MainActor.run {
            self.isAuthenticated = false
            self.currentUser = nil
            self.errorMessage = error.localizedDescription
        }
    }
}
```

**Why `MainActor.run`?**: UI updates must happen on the main thread. `MainActor.run` ensures we're updating UI properties safely.

#### 4. `signOut()` - Log out
```swift
func signOut() {
    UserDefaults.standard.removeObject(forKey: tokenKey)
    isAuthenticated = false
    currentUser = nil
}
```

**How views use it**:
```swift
struct SomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        if authManager.isAuthenticated {
            Text("Welcome \(authManager.currentUser?.login ?? "")")
        } else {
            LoginView()
        }
    }
}
```

---

## 🎨 Views (User Interface)

All views use **SwiftUI**, Apple's declarative UI framework.

**Key SwiftUI concepts**:
- [`View` protocol](https://developer.apple.com/documentation/swiftui/view): All UI components conform to this
- [`body`](https://developer.apple.com/documentation/swiftui/view/body-swift.property): Required property that returns the view's content
- [`@State`](https://developer.apple.com/documentation/swiftui/state): Private view state
- [`@StateObject`](https://developer.apple.com/documentation/swiftui/stateobject): Owns an ObservableObject
- [`@ObservedObject`](https://developer.apple.com/documentation/swiftui/observedobject): Watches an ObservableObject
- [`@EnvironmentObject`](https://developer.apple.com/documentation/swiftui/environmentobject): Shared object from parent
- [`@Environment`](https://developer.apple.com/documentation/swiftui/environment): System-provided values

---

### `Views/ContentView.swift` - Main Router

**What it does**: Decides whether to show the login screen or the main app.

**Code**:
```swift
struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                GistListView()      // ← Logged in: show gists
            } else {
                LoginView()         // ← Not logged in: show login
            }
        }
    }
}
```

**Why `Group`?**: It's a container that doesn't add any visual styling, perfect for conditional logic.

**How it works**: When `authManager.isAuthenticated` changes, SwiftUI automatically re-renders this view and shows the appropriate screen.

---

### `Views/LoginView.swift` - Authentication Screen

**What it does**: Provides UI for users to enter their GitHub personal access token.

**State variables**:
```swift
@State private var token = ""          // What user types
@State private var isLoading = false   // Show spinner?
```

**UI Components**:

1. **Icon and branding**:
```swift
Image(systemName: "doc.text.fill")
    .font(.system(size: 80))
    .foregroundColor(.blue)

Text("The Gist")
    .font(.largeTitle)
    .fontWeight(.bold)
```

2. **Token input**:
```swift
SecureField("GitHub Token", text: $token)
    .textFieldStyle(RoundedBorderTextFieldStyle())
    .autocapitalization(.none)      // Don't auto-capitalize
    .disableAutocorrection(true)    // Don't autocorrect
```

**Why `SecureField`?**: Hides the token as you type (shows dots), like a password field.

**Two-way binding (`$token`)**: The `$` creates a binding - when the user types, `token` updates, and if code changes `token`, the field updates.

3. **Error display**:
```swift
if let errorMessage = authManager.errorMessage {
    Text(errorMessage)
        .foregroundColor(.red)
}
```

4. **Sign in button**:
```swift
Button(action: signIn) {
    if isLoading {
        ProgressView()  // Spinner
    } else {
        Text("Sign In")
    }
}
.disabled(token.isEmpty || isLoading)  // Can't click if empty
```

**Sign in logic**:
```swift
private func signIn() {
    isLoading = true
    Task {
        await authManager.saveToken(token)
        await MainActor.run {
            isLoading = false
        }
    }
}
```

**Why `Task`?**: Wraps async code so we can call it from a synchronous button action.

---

### `Views/GistListView.swift` - Main Gist List

**What it does**: Shows all user's gists in a scrollable list with options to create, edit, or delete.

**Architecture**: This view uses the **MVVM (Model-View-ViewModel)** pattern:
- **Model**: `Gist` struct
- **View**: `GistListView` (UI)
- **ViewModel**: `GistListViewModel` (logic)

**State**:
```swift
@StateObject private var viewModel = GistListViewModel()
@State private var showingCreateSheet = false
@State private var showingSettings = false
```

**UI States**: The view handles three different states:

1. **Loading**:
```swift
if viewModel.isLoading {
    ProgressView("Loading gists...")
}
```

2. **Error**:
```swift
else if let errorMessage = viewModel.errorMessage {
    VStack {
        Image(systemName: "exclamationmark.triangle")
        Text(errorMessage)
        Button("Retry") { ... }
    }
}
```

3. **Empty**:
```swift
else if viewModel.gists.isEmpty {
    VStack {
        Image(systemName: "doc.text")
        Text("No gists yet")
        Button("Create Your First Gist") { ... }
    }
}
```

4. **Success (with data)**:
```swift
else {
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
```

**List features**:
- `ForEach`: Loops through gists array
- `NavigationLink`: Tappable row that navigates to detail view
- `.onDelete`: Enables swipe-to-delete
- `.refreshable`: Enables pull-to-refresh

**Toolbar**:
```swift
.toolbar {
    ToolbarItem(placement: .navigationBarLeading) {
        Button(action: { showingSettings = true }) {
            Image(systemName: "gearshape")  // ⚙️
        }
    }
    ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { showingCreateSheet = true }) {
            Image(systemName: "plus")  // +
        }
    }
}
```

**Sheets (modals)**:
```swift
.sheet(isPresented: $showingCreateSheet) {
    CreateGistView(viewModel: viewModel)
}
.sheet(isPresented: $showingSettings) {
    SettingsView()
}
```

**Task modifier**:
```swift
.task {
    await viewModel.loadGists()  // Load when view appears
}
```

---

#### `GistRowView` - Individual Row

**What it does**: Displays one gist in the list.

**Layout**:
```swift
VStack(alignment: .leading) {
    Text(gist.title)                    // Title/description
        .font(.headline)

    HStack {
        Image(systemName: gist.publicGist ? "globe" : "lock")
        Text("\(gist.files.count) file(s)")
        Spacer()
        Text(gist.updatedAt, style: .relative)  // "2 hours ago"
    }

    Text(filenames...)                  // List of files
        .lineLimit(1)
}
```

**Layout hierarchy**:
- `VStack`: Vertical stack (top to bottom)
- `HStack`: Horizontal stack (left to right)
- `Spacer()`: Pushes elements apart

---

#### `GistListViewModel` - Business Logic

**What it does**: Manages the gist list data and operations.

**Why separate from view?**:
- **Testability**: Can test logic without UI
- **Reusability**: Could use in widgets, watch app, etc.
- **Organization**: Keeps view code clean

**Properties**:
```swift
@Published var gists: [Gist] = []           // The data
@Published var isLoading = false            // Loading state
@Published var errorMessage: String?        // Error state
```

**Methods**:

1. **Load gists**:
```swift
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
```

2. **Delete gist**:
```swift
func deleteGist(_ gist: Gist) async {
    do {
        try await apiClient.deleteGist(id: gist.id)
        gists.removeAll { $0.id == gist.id }  // Remove from array
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

3. **Add gist** (after creation):
```swift
func addGist(_ gist: Gist) {
    gists.insert(gist, at: 0)  // Add to beginning
}
```

---

### `Views/GistDetailView.swift` - Edit a Gist

**What it does**: Shows a gist's content and allows editing. Also uses MVVM pattern.

**Custom initializer**:
```swift
init(gist: Gist) {
    self.gist = gist
    _viewModel = StateObject(wrappedValue: GistDetailViewModel(gist: gist))
}
```

**Why custom init?**: We need to pass the `gist` to create the ViewModel, but `@StateObject` requires special initialization syntax (`_viewModel`).

**UI States** (similar pattern to list):

1. **Loading**
2. **Error with retry**
3. **Content editor**

**Multi-file support**:
```swift
if viewModel.editableFiles.count > 1 {
    Picker("File", selection: $viewModel.selectedFileIndex) {
        ForEach(0..<viewModel.editableFiles.count, id: \.self) { index in
            Text(viewModel.editableFiles[index].filename)
        }
    }
    .pickerStyle(.segmented)  // Tab-style picker
}
```

**Text editor**:
```swift
TextEditor(text: Binding(
    get: { viewModel.fileContents[currentFile.filename] ?? "" },
    set: { viewModel.fileContents[currentFile.filename] = $0 }
))
.font(.system(.body, design: .monospaced))  // Code font
.autocapitalization(.none)
.disableAutocorrection(true)
```

**Custom binding**: We create a `Binding` that gets/sets from the dictionary.

**Save button**:
```swift
Button(action: saveGist) {
    if viewModel.isSaving {
        ProgressView()
    } else {
        Text("Save")
    }
}
.disabled(!viewModel.hasChanges || viewModel.isSaving)
```

**Alert**:
```swift
.alert("Gist Saved", isPresented: $showingSaveAlert) {
    Button("OK") { dismiss() }
} message: {
    Text("Your changes have been saved successfully.")
}
```

**Markdown preview**:
When viewing a markdown file (`.md` or `.markdown`), a preview button appears:

```swift
private var isCurrentFileMarkdown: Bool {
    guard !viewModel.editableFiles.isEmpty else { return false }
    let currentFile = viewModel.editableFiles[viewModel.selectedFileIndex]
    let filename = currentFile.filename.lowercased()
    return filename.hasSuffix(".md") || filename.hasSuffix(".markdown")
}
```

The preview button is conditionally shown in the toolbar:
```swift
ToolbarItem(placement: .navigationBarLeading) {
    if isCurrentFileMarkdown {
        Button(action: openPreview) {
            Label("Preview", systemImage: "doc.text.magnifyingglass")
        }
    }
}
```

When tapped, it opens an in-app Safari view showing GitHub's rendered markdown:
```swift
.sheet(isPresented: $showingSafariView) {
    if let url = URL(string: gist.htmlUrl) {
        SafariView(url: url)
            .ignoresSafeArea()
    }
}
```

---

#### `GistDetailViewModel` - Edit Logic

**Properties**:
```swift
@Published var editableFiles: [GistFile] = []
@Published var fileContents: [String: String] = [:]    // Current state
@Published var selectedFileIndex = 0

private var originalContents: [String: String] = [:]   // For comparison
```

**Computed property**:
```swift
var hasChanges: Bool {
    fileContents != originalContents
}
```

**Load gist content**:
```swift
func loadGistContent() async {
    isLoading = true

    do {
        let fullGist = try await apiClient.fetchGist(id: gist.id)
        editableFiles = fullGist.fileList

        // Store content in dictionary
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
```

**Save changes**:
```swift
func saveGist() async {
    isSaving = true

    // Find only changed files
    let updates = fileContents.filter { key, value in
        originalContents[key] != value
    }

    do {
        _ = try await apiClient.updateGist(
            id: gist.id,
            description: gist.description,
            files: updates
        )

        originalContents = fileContents  // Update baseline
    } catch {
        errorMessage = error.localizedDescription
    }

    isSaving = false
}
```

---

### `Views/CreateGistView.swift` - Create New Gist

**What it does**: Form for creating a new gist with description, filename, and content.

**State**:
```swift
@State private var description = ""
@State private var filename = ""
@State private var content = ""
@State private var isPublic = false
@State private var isCreating = false
@State private var errorMessage: String?
```

**Props**:
```swift
@ObservedObject var viewModel: GistListViewModel  // Parent's view model
@Environment(\.dismiss) private var dismiss        // Close sheet
```

**Form structure**:
```swift
Form {
    Section(header: Text("Gist Details")) {
        TextField("Description (optional)", text: $description)
        Toggle("Public", isOn: $isPublic)
    }

    Section(header: Text("File")) {
        TextField("Filename", text: $filename)
        TextEditor(text: $content)
            .frame(minHeight: 200)
    }
}
```

**Form vs VStack**: `Form` provides iOS-style grouped settings UI.

**Validation**:
```swift
private var isValid: Bool {
    !filename.isEmpty && !content.isEmpty
}
```

**Create action**:
```swift
private func createGist() {
    isCreating = true

    Task {
        do {
            let gist = try await GitHubAPIClient.shared.createGist(
                description: description.isEmpty ? "Untitled" : description,
                isPublic: isPublic,
                files: [filename: content]
            )

            await MainActor.run {
                viewModel.addGist(gist)  // Add to parent's list
                dismiss()                // Close sheet
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isCreating = false
            }
        }
    }
}
```

---

### `Views/SettingsView.swift` - Settings Screen

**What it does**: Shows user info and sign out option.

**Structure**:
```swift
NavigationView {
    Form {
        Section {
            // Display user info
            HStack {
                Text("Signed in as")
                Spacer()
                Text(user.login)
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
    .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done") { dismiss() }
        }
    }
}
```

**Button role**: `.destructive` makes it red to indicate caution.

**Sign out**:
```swift
private func signOut() {
    authManager.signOut()
    dismiss()
}
```

---

### `Views/SafariView.swift` - In-App Safari Wrapper

**What it does**: Wraps UIKit's `SFSafariViewController` so it can be used in SwiftUI for displaying web content in-app.

**Key concepts**:
- [`UIViewControllerRepresentable`](https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable): Protocol to bridge UIKit view controllers to SwiftUI
- [`SFSafariViewController`](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller): Full-featured in-app browser

**Why use this?**: SwiftUI doesn't have a native web view component, so we bridge UIKit's Safari view controller.

**Structure**:
```swift
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false

        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        safariViewController.preferredControlTintColor = .systemBlue

        return safariViewController
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}
```

**How it's used**:
```swift
// In GistDetailView
.sheet(isPresented: $showingSafariView) {
    if let url = URL(string: gist.htmlUrl) {
        SafariView(url: url)
            .ignoresSafeArea()
    }
}
```

**UIViewControllerRepresentable lifecycle**:
1. `makeUIViewController`: Called once to create the view controller
2. `updateUIViewController`: Called when SwiftUI state changes (not used here)

**Built-in features**: `SFSafariViewController` automatically includes:
- Navigation toolbar with Done button
- Open in Safari button
- Share button
- Reader mode (if available)
- AutoFill and password management

---

## 🎨 Assets (Images & Icons)

### `Assets.xcassets/`

**What it does**: Stores images, icons, and colors for your app.

**Structure**:
- `AppIcon.appiconset/`: App icon in various sizes for different devices
- `Contents.json`: Metadata about assets

**How to use in code**:
```swift
Image("myImageName")  // For custom images
Image(systemName: "heart.fill")  // For SF Symbols (Apple's icons)
```

---

## 🔄 Common Patterns in the Code

### 1. [Async/Await Pattern](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
```swift
Task {
    let result = try await someAsyncFunction()
    // Use result
}
```

### 2. [Published Properties](https://developer.apple.com/documentation/combine/published)
```swift
@Published var data: [Item] = []
// When data changes, views re-render
```

### 3. [State Management](https://developer.apple.com/documentation/swiftui/state-and-data-flow)
```swift
@State private var text = ""           // Local to view
@StateObject private var vm = VM()     // View owns object
@ObservedObject var vm: VM             // Someone else owns it
@EnvironmentObject var auth: Auth      // Shared globally
```

### 4. [Error Handling](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling/)
```swift
do {
    try await riskyOperation()
} catch {
    errorMessage = error.localizedDescription
}
```

### 5. [Main Actor](https://developer.apple.com/documentation/swift/mainactor)
```swift
await MainActor.run {
    // Update UI properties here
}
```

### 6. [Conditional Views](https://developer.apple.com/documentation/swiftui/viewbuilder)
```swift
if condition {
    View1()
} else {
    View2()
}
```

---

## 📚 Key iOS/Swift Concepts Used

### Swift Language Features
- **[Structs](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/classesandstructures/)**: Value types for data
- **[Classes](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/classesandstructures/)**: Reference types for managers
- **[Protocols](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/)**: Contracts (Codable, Identifiable, etc.)
- **[Optionals](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/thebasics/#Optionals)**: Values that might be nil (`String?`)
- **[Async/Await](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)**: Modern concurrency
- **[Generics](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/generics/)**: Type-safe code (`Array<Gist>`)
- **[Closures](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/closures/)**: Inline functions `{ ... }`
- **[Computed Properties](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/#Computed-Properties)**: `var title: String { ... }`

### SwiftUI Features
- **[Declarative UI](https://developer.apple.com/documentation/swiftui)**: Describe what, not how
- **[State-driven](https://developer.apple.com/documentation/swiftui/state-and-data-flow)**: UI reflects state
- **[Composition](https://developer.apple.com/documentation/swiftui/view-composition)**: Small views build big views
- **[Modifiers](https://developer.apple.com/documentation/swiftui/view-modifiers)**: Chain to customize (`.font()`, `.padding()`)
- **[View builders](https://developer.apple.com/documentation/swiftui/viewbuilder)**: Build UI with if/else/for

### iOS Patterns
- **[MVVM](https://developer.apple.com/forums/thread/699003)**: Model-View-ViewModel architecture
- **[Singleton](https://developer.apple.com/documentation/swift/managing-a-shared-resource-using-a-singleton)**: One instance (`shared`)
- **[Delegation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/#Delegation)**: Pass data between views
- **[Observation](https://developer.apple.com/documentation/combine/observableobject)**: Watch for changes (`ObservableObject`)
- **[Environment](https://developer.apple.com/documentation/swiftui/environment)**: Share data down tree

### Networking
- **[REST API](https://developer.apple.com/documentation/foundation/url_loading_system)**: HTTP requests (GET, POST, PATCH, DELETE)
- **[JSON](https://developer.apple.com/documentation/foundation/jsondecoder)**: Data format
- **[Codable](https://developer.apple.com/documentation/swift/codable)**: JSON ↔ Swift objects
- **[URLSession](https://developer.apple.com/documentation/foundation/urlsession)**: Network requests
- **[Authentication](https://developer.apple.com/documentation/foundation/url_loading_system/handling_an_authentication_challenge)**: Bearer tokens

---

## 🎓 Learning Path

If you're new to iOS development, study files in this order:

1. **Start with Models**: `Gist.swift`
   - Understand data structures
   - Learn about Codable

2. **Then Services**: `GitHubAPIClient.swift`
   - See how API calls work
   - Learn async/await

3. **Then Simple Views**: `ContentView.swift`
   - Basic SwiftUI
   - Conditional rendering

4. **Then Auth**: `AuthenticationManager.swift`
   - State management
   - ObservableObject

5. **Then Complex Views**: `GistListView.swift`
   - Lists and navigation
   - MVVM pattern

6. **Finally Advanced**: `GistDetailView.swift`
   - Complex state
   - Custom bindings

---

## 🔍 Debugging Tips

### Print debugging
```swift
print("Value: \(someVariable)")
```

### Breakpoints
- Click line number in Xcode to add breakpoint
- App pauses there, inspect variables

### Preview
```swift
struct SomeView_Previews: PreviewProvider {
    static var previews: some View {
        SomeView()
    }
}
```
See view in Xcode without running app.

---

## 📖 Additional Resources

- **Apple Documentation**: developer.apple.com
- **SwiftUI Tutorials**: developer.apple.com/tutorials/swiftui
- **Hacking with Swift**: hackingwithswift.com
- **Swift by Sundell**: swiftbysundell.com

---

This guide should help you understand not just what each file does, but *why* it's structured that way and how it fits into the bigger picture of iOS development. Happy coding! 🚀
