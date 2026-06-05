# VS Code Flutter Commands Shortcut Guide

This folder contains VS Code configurations for quick access to Flutter commands.

## 📱 Quick Keyboard Shortcuts

### Run Commands
| Shortcut | Command | Description |
|----------|---------|-------------|
| `Cmd+K Cmd+R` | Flutter: Run (Auto Device) | Run on any connected device/simulator |
| `Cmd+K Cmd+A` | Flutter: Run Android | Run on Android device/emulator |
| `Cmd+K Cmd+I` | Flutter: Run iOS Simulator | Run on iOS simulator |

### Build Commands
| Shortcut | Command | Description |
|----------|---------|-------------|
| `Cmd+K Cmd+B A` | Flutter: Build Android | Build APK for Android |
| `Cmd+K Cmd+B I` | Flutter: Build iOS (Simulator) | Build for iOS simulator |
| `Cmd+K Cmd+B D` | Flutter: Build iOS (Device) | Build for iOS device (requires code signing) |

### Utility Commands
| Shortcut | Command | Description |
|----------|---------|-------------|
| `Cmd+K Cmd+C` | Flutter: Clean & Get | Clean build and get dependencies |
| `Cmd+K Cmd+T` | Flutter: Test | Run all tests |

## 🎯 How to Use

### Option 1: Using Keyboard Shortcuts
1. Press the shortcut combination (e.g., `Cmd+K Cmd+R`)
2. Command executes immediately
3. Output appears in VS Code terminal

### Option 2: Using Command Palette
1. Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Windows/Linux)
2. Type the task name (e.g., "Flutter: Run Android")
3. Press Enter

### Option 3: Tasks Menu
1. Press `Cmd+K Cmd+P` (macOS) or `Ctrl+Shift+P` then type "Tasks: Run Task"
2. Select your task from the list

## 📋 All Available Tasks

### Core Commands
- **Flutter: Run (Auto Device)** - Auto-detect and run on available device
- **Flutter: Run Android** - Run specifically on Android
- **Flutter: Run iOS Simulator** - Run on iOS simulator
- **Flutter: Build Android** - Build APK release
- **Flutter: Build iOS (Simulator)** - Build for simulator
- **Flutter: Build iOS (Device)** - Build for physical device

### Maintenance Commands
- **Flutter: Clean & Get** - Clean build directory and fetch dependencies
- **Flutter: Clean** - Clean build artifacts
- **Flutter: Pub Get** - Fetch dependencies only
- **Flutter: Format Code** - Format all Dart files
- **Flutter: Analyze** - Run static analysis
- **Flutter: Test** - Run unit tests

## 🔐 Important Notes

### iOS Build
The iOS build tasks automatically:
1. Read credentials from `.env` file
2. Run the `ios/inject_env.sh` script
3. Inject Google Sign-In credentials into Info.plist
4. Build with proper configuration

**Make sure your `.env` file contains:**
```
GOOGLE_IOS_CLIENT_ID=...
GOOGLE_IOS_REVERSED_CLIENT_ID=...
```

### Device vs Simulator
- **Simulator builds** don't require code signing
- **Device builds** require:
  - Apple Developer Account
  - Code signing certificate
  - Provisioning profile
  - Team selected in Xcode

## ⚙️ Customization

### Edit Shortcuts
Edit `.vscode/keybindings.json` to change keyboard shortcuts:
```json
{
  "key": "your-custom-key-combination",
  "command": "workbench.action.tasks.runTask",
  "args": "Task Name Here"
}
```

### Add New Tasks
Edit `.vscode/tasks.json` to add more Flutter commands:
```json
{
  "label": "Custom Task Name",
  "type": "shell",
  "command": "flutter",
  "args": ["your", "command", "here"]
}
```

## 🐛 Troubleshooting

### Keyboard Shortcut Not Working
- Make sure you're focused in the editor (not in a different panel)
- Check if another extension uses the same shortcut
- Use Command Palette instead (`Cmd+Shift+P`)

### Task Hangs or Doesn't Complete
- Check the terminal output for errors
- Try `Cmd+K Cmd+C` (Clean & Get) first
- Restart VS Code if needed

### Build Fails
- Ensure you're in the correct directory
- Check that `.env` file exists and contains required values
- For iOS: Run `flutter clean` and rebuild

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter CLI Commands](https://flutter.dev/docs/reference/flutter-cli)
- [VS Code Tasks Documentation](https://code.visualstudio.com/docs/editor/tasks)

## 💡 Tips

1. **Use `Cmd+Shift+P`** to quickly access any task by name
2. **View running tasks**: Click the terminal tab or press `Cmd+J`
3. **Stop a task**: Press `Ctrl+C` in the terminal
4. **Use multiple terminals**: Each task can run in its own terminal panel

---

**Last Updated**: 2026-06-05
