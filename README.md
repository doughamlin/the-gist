# GitHub Gist Editor for iOS

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
- **Syntax Highlighting Info**: Display file language and type information

## Requirements

- iOS 15.0 or later
- Xcode 14.0 or later
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

### 2. Open the Project in Xcode

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd the-gist
   ```

2. Open the project in Xcode:
   ```bash
   open GistEditor/GistEditor.xcodeproj
   ```

3. Select your development team in the project settings:
   - Select the project in the navigator
   - Go to "Signing & Capabilities"
   - Select your team from the dropdown

### 3. Build and Run

1. Select a simulator or connect your iOS device
2. Click the "Run" button (▶) or press `Cmd+R`
3. The app will build and launch

### 4. Sign In

1. When the app launches, you'll see the login screen
2. Paste your GitHub Personal Access Token
3. Click "Sign In"
4. Once authenticated, you'll see your list of gists

## Project Structure

```
GistEditor/
├── GistEditor/
│   ├── GistEditorApp.swift          # Main app entry point
│   ├── Models/
│   │   └── Gist.swift                # Data models for gists
│   ├── Services/
│   │   ├── GitHubAPIClient.swift     # GitHub API integration
│   │   └── AuthenticationManager.swift # Auth state management
│   ├── Views/
│   │   ├── ContentView.swift         # Main content switcher
│   │   ├── LoginView.swift           # Authentication screen
│   │   ├── GistListView.swift        # List of all gists
│   │   ├── GistDetailView.swift      # Edit gist content
│   │   └── CreateGistView.swift      # Create new gist
│   └── Info.plist                    # App configuration
└── GistEditor.xcodeproj/             # Xcode project
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

- Tap "Sign Out" in the top-left corner of the gist list
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
- Clean the build folder (`Cmd+Shift+K`)
- Delete derived data and rebuild

## Future Enhancements

Potential features for future versions:

- Keychain integration for token storage
- Star/unstar gists
- Fork gists
- Comment on gists
- Search and filter gists
- Offline support with local caching
- iPad optimization with split view
- Dark mode refinements
- Markdown preview for .md files
- Code syntax highlighting in editor

## License

This project is provided as-is for educational and personal use.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.
