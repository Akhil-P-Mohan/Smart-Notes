# 📒 Smart Notes

Smart Notes is a Flutter-based mobile application that integrates on-device AI features such as Optical Character Recognition (OCR) using Google ML Kit. This app is designed to provide a seamless note-taking experience with text extraction from images, multilingual OCR support, and offline functionality after initial setup.

## 🚀 Setup and Build Instructions

This project requires a specific Flutter and Android build environment to work correctly. Please follow the steps carefully.

## ✅ Prerequisites

- **Flutter SDK**: Stable on 3.32.8 (with Dart 3.8.1).
  - Using other versions may cause dependency conflicts.
- **Android Studio**: Required for Android SDK management.
- **Android SDK**: Install SDK 36 (Android 15 Preview) using Android Studio's SDK Manager.
  - Some plugins specifically require this version.
- **Java Development Kit (JDK)**: Use JDK 17.
  - ⚠️ Newer versions (like JDK 21) will cause Gradle build failures.
  - Recommended: Adoptium Temurin 17 (LTS).

## 🛠️ Build Steps

### Clone the Repository

```bash
git clone https://github.com/Akhil-P-Mohan/Smart-Notes.git
cd Smart-Notes
```

### Configure Gradle to Use JDK 17

This is the most critical step to prevent build crashes. Open the `android/gradle.properties` file and add the following line, replacing the path with your local JDK 17 installation path. On Windows, use double backslashes (`\\`).

```properties
# In android/gradle.properties
# This line forces Gradle to use a stable Java version.
org.gradle.java.home=C:\\Users\\YourUser\\AppData\\Local\\Programs\\Eclipse Adoptium\\jdk-17.0.16.8-hotspot
```

### Install Dependencies

```bash
flutter pub get
```

### Run the App

Connect a physical device or start an emulator, then run:

```bash
flutter run
```

## 🔠 Note on OCR Models

- This app uses Google ML Kit for on-device OCR.
- When you select a new language for the first time (e.g., Hindi, Chinese), the app will download the required recognition model via Google Play Services. This requires an internet connection for the initial download.
- ✅ Once downloaded, the OCR model for that language works fully offline.

## 📌 Tech Stack

- **Framework**: Flutter 3.32.8 (Dart 3.8.1)
- **State Management**: flutter_riverpod
- **Database**: hive / hive_flutter
- **AI/ML**: google_mlkit_text_recognition (On-device OCR)
- **Android SDK**: 36 (Android 15 Preview)
- **Java/Gradle Config**: JDK 17 & Gradle 8.9

## 📷 Screenshots

<!-- Add your app screenshots here -->
![App Screenshot 1](screenshots/screenshot1.png)
![App Screenshot 2](screenshots/screenshot2.png)
![App Screenshot 3](screenshots/screenshot3.png)

## 🤝 Contributing

Contributions are welcome! Feel free to fork the repository, create a new branch, and submit a pull request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## 📞 Contact

- **Author**: Akhil P Mohan
- **GitHub**: [@Akhil-P-Mohan](https://github.com/Akhil-P-Mohan)
- **Project Link**: [https://github.com/Akhil-P-Mohan/Smart-Notes](https://github.com/Akhil-P-Mohan/Smart-Notes)

## 🙏 Acknowledgments

- Thanks to Google for providing ML Kit for on-device text recognition
- Flutter team for the excellent framework
- All contributors who help improve this project