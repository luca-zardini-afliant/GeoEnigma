# 🌍 Global Enigma

A cross-platform geo-detective puzzle game built with Flutter. Test your geography knowledge by guessing locations around the world!

## 💡 Project Idea

Global Enigma is an interactive geography puzzle game that challenges players to identify locations worldwide using progressive clues. The game combines educational value with entertainment, making geography learning engaging and fun.

**Core Concept**: Players are presented with a mystery location and must use strategic clue revelation to narrow down their guess. Each clue costs points, creating a risk-reward dynamic that encourages critical thinking and geographical knowledge.

**Key Innovation**: The progressive clue system allows players to choose their difficulty path - they can play conservatively with fewer clues or take risks for higher scores. The distance-based scoring system rewards precision while the achievement system provides long-term engagement.

**Educational Value**: Players naturally learn about world geography, landmarks, and cultural references through gameplay. The three difficulty levels (nations, cities, monuments) cater to different knowledge levels, making it accessible to both geography enthusiasts and casual learners.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (>=3.0.0)
- For Android: Android SDK and Android Studio
- For Web: Any modern web browser

### Installation & Execution

1. **Clone and setup**
   ```bash
   git clone https://github.com/luca-zardini-afliant/GeoEnigma.git
   cd GeoEnigma
   flutter pub get
   ```

2. **Run the application**
   
   **Web (Recommended for testing):**
   ```bash
   flutter run -d chrome --web-port=8080
   ```
   Open: `http://localhost:8080`
   
   **Android:**
   ```bash
   flutter run
   ```

3. **Build for production**
   
   **Web:**
   ```bash
   flutter build web --release
   ```
   
   **Android APK:**
   ```bash
   flutter build apk --release
   ```

## 🎮 How to Play

1. **Select Difficulty**: Choose Easy (nations), Medium (cities), or Hard (monuments)
2. **Reveal Clues**: Use the dossier to reveal clues - each costs points
3. **Make Your Guess**: Tap on the world map to place your guess
4. **Confirm & Score**: See your results and final score

## 🎯 Game Features

- **Progressive Clue System**: Strategic clue revelation with point costs
- **Interactive World Map**: Tap-to-guess interface with distance calculation
- **Smart Scoring**: Distance penalty + bullseye bonus system
- **User Profiles**: Local stats tracking and achievement system
- **Cross-Platform**: Runs on Web and Android from single codebase
- **Offline Play**: No internet connection required
- **Modern UI**: Material Design 3 with dark mode support
- **Sound Effects**: Audio feedback for enhanced experience
- **Timer Mode**: Optional countdown timer for added challenge

## 🏗️ Technical Stack

- **Flutter** - Cross-platform framework
- **flutter_map** - Interactive map component with tile layers
- **SharedPreferences** - Local data persistence
- **Material Design 3** - Modern UI components
- **Audio Players** - Sound effects and feedback

## 📱 Platform Support

**Web App**: Runs in any modern browser with responsive design and touch/mouse support.

**Android App**: Native performance with offline functionality and touch-optimized interface.

## 🎨 Customization

- **Puzzle Data**: Edit `assets/data/puzzles.json` to add/modify locations
- **Achievements**: Modify achievement system in `user_profile.dart`
- **Scoring**: Adjust scoring logic in `game_screen.dart`
- **UI Theme**: Customize colors and styling throughout the app

## 📄 License

This project is part of a hackathon and is available for educational purposes.

---

**Built with ❤️ using Flutter for the Global Enigma hackathon**