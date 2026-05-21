# Music AI Code Challenge

An iOS music discovery app that searches the iTunes catalog, plays song previews, and keeps track of recently played music. Built with SwiftUI and a clean MVVM architecture.

---

## Project overview

### Main features

- **Splash screen** — Branded launch screen shown briefly when the app starts.
- **Songs screen (Home)** — Search iTunes for songs, browse results, and see recently played tracks when the search field is empty.
- **Song details (Player)** — Expanded and minimized player with artwork, playback controls, timeline, and previous/next track navigation within the current list.
- **Album screen** — Album artwork, title, artist, and track list loaded from iTunes; tap a track to play it.
- **Recently played** — Last played songs stored locally with SwiftData (up to 10 items).
- **Localization** — English and Portuguese (Brazil) strings.
- **Light & dark mode** — UI adapts automatically using system semantic colors.

### Technologies

| Area | Technology |
|------|------------|
| UI | SwiftUI |
| Architecture | MVVM, protocol-oriented services (SOLID) |
| Networking | iTunes Search & Lookup APIs (`URLSession`) |
| Concurrency | Swift `async`/`await`, `Task`, `@MainActor` |
| Audio | `AVPlayer` |
| Persistence | SwiftData (recently played songs) |
| Localization | `Localizable.strings` (en, pt-BR) |
| Unit tests | Swift Testing framework |

### App flow

1. Splash screen (2 seconds) → Songs screen  
2. Search or pick a recent song → Player opens  
3. **View album** (minimized player) → Album screen  
4. Tap a track on the album → Returns to playback with the album as the queue  

---

## Screenshots

_Add screenshots below after running the app on a simulator or device._

### Splash screen

<!-- Replace with: screenshot-splash-light.png / screenshot-splash-dark.png -->

| Light mode | Dark mode |
|------------|-----------|
| _Add screenshot_ | _Add screenshot_ |

### Songs screen (Home)

<!-- Replace with: screenshot-songs-light.png / screenshot-songs-dark.png -->

| Light mode | Dark mode |
|------------|-----------|
| _Add screenshot_ | _Add screenshot_ |

### Song details (Player)

<!-- Replace with: screenshot-player-expanded-light.png / screenshot-player-minimized-dark.png -->

| Expanded | Minimized |
|----------|-----------|
| _Add screenshot_ | _Add screenshot_ |

### Album screen

<!-- Replace with: screenshot-album-light.png / screenshot-album-dark.png -->

| Light mode | Dark mode |
|------------|-----------|
| _Add screenshot_ | _Add screenshot_ |

---

## Requirements

- **macOS** with **Xcode** installed (project targets **iOS 26.4**)
- An **iOS Simulator** or a physical iPhone running a compatible iOS version

---

## How to run the app in Xcode

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd music-ai-code-challenge
   ```

2. **Open the project in Xcode**
   - Open `Music AI Code Challenge/Music AI Code Challenge.xcodeproj`
   - Or open the repository folder in Xcode and select the project when prompted.

3. **Select a run destination**
   - In the Xcode toolbar, choose an **iOS Simulator** (for example, iPhone 17) or a connected device.

4. **Run the app**
   - Press **⌘R** (Product → Run), or click the **Play** button.

No extra setup steps are required: there are no API keys, environment files, or package installs beyond what Xcode resolves automatically.

> **Note:** Song previews stream from iTunes and require an internet connection. Search and album data also come from the iTunes API.

---

## Unit tests

### How to run unit tests

**In Xcode**

1. Open the project as described above.
2. Press **⌘U** (Product → Test), or  
   - Open the **Test navigator** (⌘6), then click the play button next to **Music AI Code ChallengeTests**.

**From the command line**

```bash
cd "Music AI Code Challenge"
xcodebuild test \
  -scheme "Music AI Code Challenge" \
  -destination "platform=iOS Simulator,name=iPhone 17" \
  -only-testing:"Music AI Code ChallengeTests"
```

Replace the simulator name if needed (`xcrun simctl list devices available`).

### What is being tested

Tests focus on **logic and behavior**, not SwiftUI layout snapshots. Network and audio hardware are never used in tests.

| Layer | Coverage |
|-------|----------|
| **Models** | `Song` card subtitles, playability; `MusicPlayerModel` initialization and album navigation flag |
| **Mappers** | `ITunesSongMapper` and `ITunesAlbumMapper` — DTO → domain models, invalid data, artwork URL handling |
| **Services** | `ITunesSongsService` with a mock API client; production `MockSongsService` catalog filtering |
| **View models** | `SongsViewModel` (search, recents, player, album route), `MusicPlayerViewModel` (playback, playlist, seek), `AlbumViewModel` (load album, errors, song selection) |

### How tests are implemented

The test target follows common iOS and SOLID practices:

1. **Protocol-based mocks (Dependency Inversion)**  
   View models and services depend on protocols (`SongsFetching`, `AlbumFetching`, `AudioPlaying`, `RecentlyPlayedStoring`, `ITunesSearchAPIClient`). Tests inject doubles from `Music AI Code ChallengeTests/TestSupport/Mocks/`.

2. **Shared fixtures**  
   `SongFixtures` and `ITunesFixtures` build consistent sample data so tests stay readable and stable.

3. **Swift Testing**  
   Suites use `@Suite` and `@Test` with `#expect`. View model tests run on `@MainActor` to match production isolation.

4. **No real I/O**  
   - iTunes responses are simulated via `MockITunesSearchAPIClient` and `MockAlbumFetching`.  
   - Audio is simulated via `MockAudioPlaying` (play/pause/seek counters, no `AVPlayer`).  
   - Recently played uses `MockRecentlyPlayedStore` instead of SwiftData in unit tests.

5. **Testability in production code**  
   `SongsViewModel` accepts an injectable `searchDebounceDuration` so tests can use `.zero` and avoid waiting for the 1-second search debounce.

**Test folder structure**

```
Music AI Code ChallengeTests/
├── TestSupport/
│   ├── Fixtures/     # Song & iTunes sample data
│   └── Mocks/        # Protocol test doubles
├── Models/
├── Mappers/
├── Services/
└── ViewModels/
```

---

## Project structure (main app)

```
Music AI Code Challenge/
├── Music AI Code Challenge/
│   ├── Views/          # Splash, Songs, MusicPlayer, Album
│   ├── ViewModels/
│   ├── Components/     # SongCardView
│   ├── Models/
│   ├── Services/       # iTunes, Audio, Persistence
│   └── Resources/      # Assets, Localizable.strings
└── Music AI Code ChallengeTests/
```
