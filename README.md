# 🌍 Global Enigma

A cross-platform geo-detective puzzle game built with Flutter. Test your geography knowledge by guessing locations around the world!

## 🎮 Features

- **Three Difficulty Levels:**
  - 🟢 **Easy**: Nations and countries
  - 🟠 **Medium**: Cities and urban locations  
  - 🔴 **Hard**: Monuments and landmarks

- **Progressive Clue System**: Reveal clues with point costs
- **Interactive World Map**: Tap to place your guess
- **Scoring System**: Distance penalty + bullseye bonus
- **User Profile & Stats**: Track your progress locally
- **Achievement System**: Unlock 8 different achievements
- **Offline Play**: No internet connection required

## 🏗️ Built With

- **Flutter** - Cross-platform framework
- **flutter_map** - Interactive map component
- **SharedPreferences** - Local data storage
- **Material Design 3** - Modern UI components

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- For Android: Android SDK and Android Studio
- For Web: Any modern web browser

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd GeoEnigma
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**

   **For Web:**
   ```bash
   flutter run -d chrome
   ```

   **For Android:**
   ```bash
   flutter run
   ```

## 📱 Cross-Platform Support

This app runs on both **Web** and **Android** from the same codebase:

### Web App
- ✅ Runs in any modern browser
- ✅ Local storage via browser APIs
- ✅ Responsive design
- ✅ Touch and mouse support

### Android App
- ✅ Native Android performance
- ✅ Local storage via SharedPreferences
- ✅ Touch-optimized interface
- ✅ Offline functionality

## 🎯 How to Play

1. **Choose Difficulty**: Select Easy, Medium, or Hard
2. **Reveal Clues**: Use the dossier to reveal clues (costs points)
3. **Make Your Guess**: Tap on the world map to place your guess
4. **Confirm**: Press "Confirm Guess" to see results
5. **Track Progress**: View your stats and achievements in the profile

## 🏆 Scoring System

- **Starting Score**: 10,000 points
- **Clue Costs**: Each clue subtracts points (varies by difficulty)
- **Distance Penalty**: 2 points per kilometer from correct location
- **Bullseye Bonus**: +500 points if within 25km of target

## 📊 User Profile Features

- **Overall Statistics**: Total games, best score, average score
- **Difficulty Breakdown**: Stats for each difficulty level
- **Achievement System**: 8 unlockable achievements
- **Local Storage**: All data stored on device (no internet required)

## 🛠️ Development

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── puzzle_model.dart    # Game puzzle data
│   └── user_profile.dart    # User stats and achievements
├── screens/                  # UI screens
│   ├── start_screen.dart    # Difficulty selection
│   ├── game_screen.dart     # Main game interface
│   └── profile_screen.dart  # User profile and stats
├── services/                 # Business logic
│   ├── puzzle_service.dart  # Puzzle data management
│   └── user_storage_service.dart # Local storage
└── widgets/                  # Reusable UI components
    ├── clue_dossier.dart    # Clue reveal interface
    └── score_display.dart   # Score display widget
```

### Building for Production

**Web:**
```bash
flutter build web --release
```

**Android:**
```bash
flutter build apk --release
```

## 🎨 Customization

- **Puzzle Data**: Edit `assets/data/puzzles.json` to add/modify puzzles
- **Achievements**: Modify `Achievements.all` in `user_profile.dart`
- **Scoring**: Adjust scoring logic in `game_screen.dart`
- **UI Theme**: Customize colors and styling in `main.dart`

## 📄 License

This project is part of a hackathon and is available for educational purposes.

## 🤝 Contributing

This is a hackathon project, but feel free to fork and improve!

---

**Built with ❤️ using Flutter for the Global Enigma hackathon**