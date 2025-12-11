# The Gist - GitHub Gist Editor for iOS

A native iOS application that allows you to view, create, edit, and manage your GitHub gists directly from your iPhone or iPad.

## Features

- **Authentication**: Secure login using GitHub Personal Access Tokens
- **View Gists**: Browse all your gists in a clean, organized list
- **Edit Gists**: Edit gist content with a monospaced code editor
- **Create Gists**: Create new gists with custom descriptions and filenames
- **Delete Gists**: Remove gists you no longer need
- **Multi-file Support**: Handle gists with multiple files
- **Public/Private**: Create both public and private gists
- **Real-time Updates**: Pull to refresh to sync with GitHub
- **Markdown Preview**: In-app preview for markdown files with option to open in Safari
- **Syntax Highlighting Info**: Display file language and type information

## Requirements

- macOS with Xcode 14.0 or later
- iOS 15.0 or later (deployment target)
- A GitHub account
- GitHub Personal Access Token with `gist` scope

## Setup Instructions

### 1. Get a GitHub Personal Access Token

1. Go to [GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens)
2. Click "Generate new token" > "Generate new token (classic)"
3. Give your token a descriptive name (e.g., "iOS Gist Editor")
4. Select the **gist** scope (this is required for reading and writing gists)
5. Click "Generate token"
6. **Important**: Copy the token immediately - you won't be able to see it again!

### 2. Open the Xcode Project

The Xcode project is already included in the repository:

1. Navigate to the `the-gist/TheGist` folder
2. Double-click `TheGist.xcodeproj` to open it in Xcode
3. When Xcode opens, you should see the project structure with all source files already included

### 3. Configure Your Development Team

After opening the project:

1. Click on the project in the Project Navigator (the blue "TheGist" icon at the top)
2. Under "Targets", select "TheGist"
3. In the "Signing & Capabilities" tab, select your development team
4. If you don't have a team, you can use a personal team (your Apple ID)

### 4. Verify Deployment Target

1. Click on your project in the Project Navigator
2. Under "Targets", select "TheGist"
3. In the "General" tab, set "Minimum Deployments" to iOS 15.0 or later

### 5. Build and Run

1. Select a simulator or connect your iOS device
2. Click the "Run" button (▶) or press `Cmd+R`
3. The app will build and launch

### 6. Sign In

1. When the app launches, you'll see the login screen
2. Paste your GitHub Personal Access Token
3. Click "Sign In"
4. Once authenticated, you'll see your list of gists

---

## Installing on Your iPhone (Without App Store)

You can install the app directly on your iPhone from Xcode without publishing to the App Store. This is called "sideloading" or development installation.

### Prerequisites

- A Mac with Xcode installed
- A USB cable to connect your iPhone to your Mac
- An Apple ID (free - doesn't require a paid developer account)

### Steps to Install

#### 1. Connect Your iPhone

1. Connect your iPhone to your Mac using a USB cable
2. On your iPhone, you may see an alert asking to "Trust This Computer"
3. Tap "Trust" and enter your iPhone passcode if prompted
4. On your Mac, you may need to click "Trust" in a popup dialog

#### 2. Select Your iPhone in Xcode

1. Open the TheGist project in Xcode
2. At the top of the Xcode window, you'll see the device selector (next to the Run button)
3. Click on it and select your iPhone from the list
   - It should appear under "iOS Device" with your iPhone's name
   - If you don't see it, make sure your iPhone is unlocked and connected

#### 3. Configure Signing (First Time Only)

1. In Xcode's Project Navigator, click on the blue "TheGist" project icon
2. Select "TheGist" under Targets
3. Go to the "Signing & Capabilities" tab
4. Under "Team", select your Apple ID
   - If you don't see your Apple ID, click "Add Account..." and sign in
   - You can use a free Apple ID - no paid developer account needed
5. Xcode will automatically create a provisioning profile for you

#### 4. Build and Run on Your iPhone

1. With your iPhone selected as the destination, click the Run button (▶) or press `Cmd+R`
2. Xcode will build the app and install it on your iPhone
3. You may see a progress bar on your iPhone showing the installation

#### 5. Trust the Developer Certificate (First Time Only)

When you first run the app, iOS will prevent it from launching because it's from an "untrusted developer." Here's how to fix this:

1. On your iPhone, go to **Settings** > **General** > **VPN & Device Management**
   - On some iOS versions, this might be called **Profiles & Device Management**
2. Under "Developer App", you'll see your Apple ID email
3. Tap on your Apple ID
4. Tap "Trust [Your Apple ID]"
5. Tap "Trust" again in the confirmation dialog

#### 6. Launch the App

1. Go back to your home screen
2. Find the "The Gist" app icon
3. Tap to launch it
4. The app will now run normally on your iPhone!

### Important Notes

**App Expiration**: Apps installed this way expire after 7 days (with a free Apple ID). After 7 days:
- The app will stop launching
- Your data remains safe on your device
- Simply reconnect your iPhone to your Mac and rebuild from Xcode to refresh for another 7 days
- If you have a paid Apple Developer account ($99/year), apps last for 1 year

**Wireless Debugging** (Optional): Once set up, you can install updates wirelessly:
1. In Xcode, go to Window > Devices and Simulators
2. Select your iPhone
3. Check "Connect via network"
4. You can now run and update the app without a cable (when on the same Wi-Fi network)

**Multiple Devices**: You can install the app on multiple iPhones/iPads using the same process

**No Data Loss**: Your gists are stored on GitHub, so even if the app expires, your data is safe. Just rebuild to access it again.

---

## Project Structure

```
TheGist/
├── TheGist/
│   ├── TheGistApp.swift              # Main app entry point
│   ├── Assets.xcassets/              # App icons and assets
│   ├── Models/
│   │   └── Gist.swift                # Data models for gists
│   ├── Services/
│   │   ├── GitHubAPIClient.swift     # GitHub API integration
│   │   └── AuthenticationManager.swift # Auth state management
│   └── Views/
│       ├── ContentView.swift         # Main content switcher
│       ├── LoginView.swift           # Authentication screen
│       ├── GistListView.swift        # List of all gists
│       ├── GistDetailView.swift      # Edit gist content
│       ├── CreateGistView.swift      # Create new gist
│       ├── SettingsView.swift        # Settings and sign out
│       └── SafariView.swift          # In-app Safari for previews
└── TheGist.xcodeproj/                # Xcode project (you create this)
```

## Usage Guide

### Viewing Gists

- Launch the app and sign in
- Your gists will be displayed in a list
- Each gist shows:
  - Title (description or first filename)
  - Public/private status
  - Number of files
  - Last updated time
  - List of filenames

### Editing a Gist

1. Tap on any gist in the list
2. If the gist has multiple files, use the segment control to switch between them
3. Edit the content in the text editor
4. Tap "Save" to push changes to GitHub
5. Changes are saved when you see the success alert

### Previewing Markdown Files

1. When viewing a markdown file (`.md` or `.markdown`), a preview button appears in the navigation bar
2. Tap the preview button (magnifying glass icon) to see the rendered markdown
3. The preview opens in an in-app Safari view showing GitHub's formatted version
4. Tap "Done" to return to editing, or use the toolbar to open in Safari

### Creating a New Gist

1. Tap the "+" button in the navigation bar
2. Enter a description (optional)
3. Toggle "Public" on/off as desired
4. Enter a filename
5. Type or paste your content
6. Tap "Create" to save to GitHub

### Deleting a Gist

1. In the gist list, swipe left on any gist
2. Tap "Delete"
3. The gist will be removed from GitHub

### Refreshing

- Pull down on the gist list to refresh and sync with GitHub

### Signing Out

- Tap the settings icon (gear) in the top-left corner of the gist list
- Tap "Sign Out" in the settings screen
- Your token will be removed from the device

## API Integration

The app uses the GitHub REST API v3:

- `GET /gists` - List all gists
- `GET /gists/:id` - Get a specific gist with content
- `POST /gists` - Create a new gist
- `PATCH /gists/:id` - Update a gist
- `DELETE /gists/:id` - Delete a gist
- `GET /user` - Verify authentication token

All API calls include the Bearer token in the Authorization header.

## Security

- Tokens are stored securely using UserDefaults (for this prototype)
- For production use, consider migrating to Keychain for enhanced security
- The app never stores your GitHub password, only the access token
- Tokens can be revoked at any time from GitHub settings

## Troubleshooting

### "Unauthorized" Error

- Verify your token has the `gist` scope
- Check that you copied the token correctly
- Try generating a new token

### "Invalid Response" Error

- Check your internet connection
- Verify GitHub API is accessible
- Try refreshing the gist list

### Build Errors in Xcode

- Make sure you're using Xcode 14.0 or later
- Verify iOS deployment target is set to 15.0 or later
- Clean the build folder (`Cmd+Shift+K`)
- Delete derived data and rebuild

### Files Not Showing in Xcode

- Make sure you added the files as references (not copies)
- Try removing and re-adding the files
- Check that the target membership is correct

## Architecture

### Models
- **Gist**: Main gist data structure with files, metadata, and owner info
- **GistFile**: Individual file within a gist
- **GistOwner**: Owner/author information
- Request/response types for API operations

### Services
- **GitHubAPIClient**: Handles all HTTP requests to GitHub API
  - Async/await pattern for modern Swift concurrency
  - Error handling with custom `APIError` types
  - Token-based authentication
- **AuthenticationManager**: ObservableObject managing auth state
  - Token storage and retrieval
  - User session management
  - Token verification

### Views (SwiftUI)
- **TheGistApp**: App entry point with environment setup
- **ContentView**: Routes between login and main app
- **LoginView**: Token input and authentication
- **GistListView**: Master list with MVVM pattern
- **GistDetailView**: Edit view with multi-file support and markdown preview
- **CreateGistView**: New gist creation form
- **SettingsView**: User info and sign out functionality
- **SafariView**: UIViewControllerRepresentable wrapper for in-app Safari

## Future Enhancements

Potential features for future versions:

- Keychain integration for secure token storage
- Star/unstar gists
- Fork gists
- Comment on gists
- Search and filter gists
- Offline support with local caching
- iPad optimization with split view
- Code syntax highlighting in editor
- Multi-file editing in one gist
- Drag and drop file management

## License

This project is provided as-is for educational and personal use.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.
