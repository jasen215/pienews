# PieNews

[简体中文](README_CN.md)

PieNews is a Flutter-based RSS reader client powered by The Old Reader service. It provides a modern and user-friendly interface for reading and managing your RSS subscriptions.

## Features

- The Old Reader account integration and synchronization
- Offline reading and caching support
- Article sharing functionality
- Multi-language localization
- Image caching
- Responsive layout design
- Cross-platform support: iOS, Android, macOS, Linux, Windows, Web

## services supported

- [x] theoldreader
- [x] feedbin
- [ ] feedly
- [ ] inoreader
- [ ] bazqux
- [ ] fever
- [ ] feedreader

## Tech Stack

- Flutter SDK (>=3.0.0)
- Provider for state management
- SQLite for local storage
- HTTP networking
- Flutter HTML rendering
- Image cache management

## Dependencies

Main dependencies include:

- provider: ^6.0.5 (State management)
- http: ^1.1.0 (Network requests)
- shared_preferences: ^2.2.1 (Local storage)
- flutter_html: ^3.0.0-beta.2 (HTML rendering)
- sqflite: ^2.3.0 (SQLite database)
- cached_network_image: ^3.3.0 (Image caching)
- url_launcher: ^6.1.14 (URL handling)
- intl: ^0.19.0 (Internationalization)

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/pienews.git
cd pienews
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the project:

```bash
flutter run
```

## Building for Release

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

### Desktop (Windows/macOS/Linux)

```bash
flutter build <platform> --release
```

## Project Structure

```
lib/
  ├── main.dart              # Application entry point
  ├── models/               # Data models
  ├── screens/              # UI screens
  ├── services/             # Services layer
  ├── widgets/              # Reusable components
  └── utils/               # Utility classes
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Contact

If you have any questions or suggestions, please open an issue for discussion.
