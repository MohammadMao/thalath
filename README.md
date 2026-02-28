
<img width="100" height="100" alt="logo" src="https://github.com/user-attachments/assets/06c264c5-1a79-4343-a528-5968e15f2e14" />

# Thalath (ثلاث)

A real-time multiplayer Arabic word game built with Flutter and Firebase. Players take turns transforming three-letter Arabic words by replacing one letter at a time, creating a chain of valid words.

## 🎮 Game Overview

**Thalath** (meaning "three" in Arabic) is a turn-based word puzzle game where players compete to form valid three-letter Arabic words. Each player starts with a hand of 15 Arabic letters and must strategically replace one letter in the current word to create a new valid word.

### How to Play

1. **Start with a word**: The game begins with a three-letter Arabic word
2. **Replace a letter**: On your turn, tap a letter in the current word and replace it with a letter from your hand
3. **Form valid words**: The new word must be a valid three-letter Arabic word
4. **Time pressure**: Each turn has a timer (10-15 seconds) to keep the game moving
5. **Strategic play**: The replaced letter returns to your hand, so plan your moves carefully
6. **Win condition**: Last player able to make a valid play wins!

## ✨ Features

- 🌐 **Real-time Multiplayer**: Play with up to 4 players simultaneously
- 🔥 **Firebase Integration**: Real-time game state synchronization with Cloud Firestore
- 🔐 **Authentication**: Secure user login and session management
- 💬 **In-game Chat**: Communicate with other players
- 🎵 **Sound Effects**: Audio feedback for game actions
- ⏱️ **Turn Timer**: Configurable timer to maintain game pace
- 🏆 **Lobby System**: Create or join game rooms
- 📱 **Cross-Platform**: Supports both Android, and Web
- 🌙 **Dark Theme**: Beautiful dark mode UI with custom theming
- 🌍 **Localization Ready**: Built with easy_localization support

## 🛠️ Tech Stack

### Core Technologies
- **Flutter** (SDK ^3.8.1) - Cross-platform UI framework
- **Dart** - Programming language
- **Firebase Core** - Backend infrastructure
- **Firebase Auth** - User authentication
- **Cloud Firestore** - Real-time database

### State Management & Architecture
- **GetX** - State management, routing, and dependency injection
- **Get_it** - Service locator for dependency injection

### UI & Design
- **flutter_screenutil** - Responsive design across devices
- **flutter_svg** - SVG rendering for icons and graphics
- **Material Design 3** - Modern UI components

### Development Tools
- **freezed** - Code generation for immutable classes
- **json_serializable** - JSON serialization/deserialization
- **flutter_lints** - Code quality and style enforcement
- **logging** - Application logging

### Additional Features
- **audioplayers** - Sound effects playback
- **easy_localization** - Multi-language support
- **dio & retrofit** - HTTP networking (prepared for future API integration)

## 📋 Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Firebase account with a configured project
- Android Studio / Xcode (for mobile platforms)
- Visual Studio (for Windows builds)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/MohammadMao/thalath.git
cd thalath
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable **Firebase Authentication** and **Cloud Firestore**
3. Add your platform-specific Firebase configuration files:
   - Android: `android/app/google-services.json`
   - Web: Update `lib/firebase_options.dart`

### 4. Run the App

```bash
# For development
flutter run
```

### Preview
<img width="250" height="500" alt="preview" src="https://github.com/user-attachments/assets/f2e9b5bc-e4f4-4bff-b634-0f50a80b6dc9" />
<img width="250" height="500" alt="preview" src="https://github.com/user-attachments/assets/cbf7471d-b553-424f-8075-dbbaf448789a" />
<img width="250" height="500" alt="preview" src="https://github.com/user-attachments/assets/592c0c02-ffb6-4d55-bf63-d10e88e6ec97" />

<img width="250" height="500" alt="preview" src="https://github.com/user-attachments/assets/8ed4401a-90c0-4eb3-9f17-720e690d6b2a" />
<img width="250" height="500" alt="preview" src="https://github.com/user-attachments/assets/4a047032-7e86-4fc3-8981-c530545d140f" />


## 📄 License

This project is private and not published to pub.dev.

## 🐛 Known Issues

- Dictionary validation is currently bypassed for testing (line 84 in `game_engine.dart`)

## 📞 Support

For issues, questions, or suggestions, please open an issue in the repository.
