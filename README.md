# Dartotsu-Kitsu

<p align="center">
   <img src="https://files.catbox.moe/mdn05t.png" alt="Dartotsu-Kitsu Banner" width="100%">
</p>

<p align="center">
   <img src="https://img.shields.io/badge/platforms-android_ios_windows_linux_macos-06599d?style=for-the-badge&labelColor=ff6b35&color=0d1117"/>
   <a href="https://github.com/Tarke4618/Dartotsu-kitsu/releases"><img src="https://img.shields.io/github/downloads/Tarke4618/Dartotsu-kitsu/total?label=Downloads&logo=android&logoColor=ff6b35&style=for-the-badge&labelColor=ff6b35&color=0d1117"></a>
</p>

<p align="center">
   <a href="https://github.com/Tarke4618/Dartotsu-kitsu/releases/latest"><img src="https://img.shields.io/github/v/release/Tarke4618/Dartotsu-kitsu?style=for-the-badge&logoColor=ff6b35&label=Latest&labelColor=ff6b35&color=0d1117" alt="Latest Release"/></a>
   <a href="https://github.com/Tarke4618/Dartotsu-kitsu/stargazers"><img src="https://img.shields.io/github/stars/Tarke4618/Dartotsu-kitsu?style=for-the-badge&label=Stars&labelColor=ff6b35&color=0d1117" alt="Stars" /></a>
</p>

---

**Dartotsu-Kitsu** is a fork of [Dartotsu](https://github.com/aayush2622/Dartotsu) with added **[Kitsu](https://kitsu.io/)** integration support!

Track your anime and manga across multiple platforms with a single, beautiful app.

## ✨ Features

- 🎯 **Kitsu Integration** - Full Kitsu account sync and tracking support
- 📊 **Multi-Platform Tracking** - AniList, MyAnimeList, Kitsu, and Simkl
- 🌍 **Cross-Platform** - Android, iOS, Windows, Linux, and macOS
- 🎨 **Beautiful UI** - Modern, fluid design with animations
- 🔄 **Sync Across Services** - Keep your lists synchronized
- 📱 **Native Performance** - Built with Flutter for smooth experience

## 📥 Downloads

| Platform    | Download                                                                      |
| ----------- | ----------------------------------------------------------------------------- |
| **Android** | [Latest Release](https://github.com/Tarke4618/Dartotsu-kitsu/releases/latest) |
| **iOS**     | [Latest Release](https://github.com/Tarke4618/Dartotsu-kitsu/releases/latest) |
| **Windows** | [Latest Release](https://github.com/Tarke4618/Dartotsu-kitsu/releases/latest) |
| **Linux**   | [Latest Release](https://github.com/Tarke4618/Dartotsu-kitsu/releases/latest) |
| **macOS**   | [Latest Release](https://github.com/Tarke4618/Dartotsu-kitsu/releases/latest) |

## 🚀 What's Different from Dartotsu?

This fork adds:

- ✅ **Kitsu OAuth Login** - Authenticate with your Kitsu account
- ✅ **Kitsu Profile Sync** - View your Kitsu profile and avatar
- ✅ **Kitsu Library Management** - Track anime/manga on Kitsu

## 🛠️ Building from Source

### Prerequisites

- Flutter SDK 3.35.7+
- Dart SDK 3.4.3+

### Build Commands

```bash
# Clone the repository
git clone https://github.com/Tarke4618/Dartotsu-kitsu.git
cd Dartotsu-kitsu

# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Build for your platform
flutter build apk --release              # Android APK
flutter build appbundle --release        # Android App Bundle
flutter build ios --release              # iOS
flutter build windows --release          # Windows
flutter build linux --release            # Linux
flutter build macos --release            # macOS
```

## ⚠️ Disclaimer

> **Dartotsu-Kitsu is a tracking and management tool only:** It does not host, provide, distribute, or maintain streaming content or extensions.
>
> **User Responsibility:** Users are solely responsible for how they use the app and any third-party services or extensions they choose to interact with. Users must comply with all applicable laws, copyright, and intellectual property rights.

## 🙏 Acknowledgments

- [Dartotsu](https://github.com/aayush2622/Dartotsu) - The original project this is forked from
- [Dantotsu](https://git.rebelonion.dev/rebelonion/Dantotsu/) - The inspiration behind Dartotsu
- [Kitsu](https://kitsu.io/) - For their awesome API

## 📄 License

Dartotsu-Kitsu is licensed under the Unabandon Public License (UPL). See [LICENSE.md](LICENSE.md) for details.
