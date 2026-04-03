# Euclid — Mental Math Training

A simple, offline mental math training app for iOS. Built with SwiftUI and SwiftData, designed to sharpen your arithmetic skills through daily practice.

## What it does

Euclid generates math problems across 10 operation types and lets you solve them against the clock or in fixed-count sessions. It tracks your stats over time so you can see yourself improving.

**Operations:** Addition, Subtraction, Multiplication, Division, Square, Square Root, Exponent (up to 5th power), Percentage, Fraction, Mixed

**Game modes:**
- **Timed** — solve as many problems as you can in 45s, 90s, 180s, or unlimited time
- **Task Count** — solve a fixed number of problems (10, 20, 50, or 100)

**Difficulty levels:**
- 1–100 (beginner)
- 100–1,000 (intermediate)
- 1,000–10,000 (advanced)
- Adaptive (adjusts based on your accuracy over the last 10 problems)

**Other features:**
- Toggle decimals and negative numbers on/off
- Answer format preview showing expected digit layout
- Anti-repeat logic to avoid consecutive duplicate problems
- Speed-based scoring with personal best tracking
- Daily streak counter
- Stats dashboard with weekly accuracy chart and per-operation breakdown
- Session history with per-problem drill-down
- Haptic feedback and programmatic sound effects (no audio files)
- Daily reminder notifications
- Skip button for problems you want to pass on
- End session early with progress saved

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData |
| Architecture | MVVM |
| Charts | Swift Charts |
| Target | iOS 17.0+ |
| Dependencies | None |

Everything runs on-device. No backend, no accounts, no network calls, no third-party libraries.

## Project Structure

```
MathBooster/
├── App/                  # Entry point and tab navigation
├── Models/               # Data types (operations, problems, sessions, settings)
├── ViewModels/           # Game logic, stats aggregation, settings management
├── Views/
│   ├── Home/             # Start screen with streak and quick stats
│   ├── Game/             # Game play, number pad, results
│   ├── Stats/            # Charts, session history, operation breakdown
│   └── Settings/         # Operations, difficulty, game mode, preferences
├── Services/             # Problem generation, difficulty engine, haptics, sound
└── Utilities/            # Constants and extensions
```

## Building

1. Open the `.xcodeproj` in Xcode 15+
2. Set the signing team to your Apple Developer account
3. Build and run on a simulator or device (iOS 17+)

No packages to install, no configuration needed.

## License

MIT License — see [LICENSE](LICENSE) for details.
