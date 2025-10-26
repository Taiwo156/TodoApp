TodoApp 📱
A modern, cross-platform todo application built with Flutter and Firebase, designed to help you manage your tasks efficiently with real-time synchronization across all your devices.

🌟 Features
🔐 Authentication
Email/Password Login & Registration

Google Sign-In integration

Password Reset functionality

Auto-login persistence

📝 Task Management
Create, Edit, Delete tasks with rich text

Due Dates with calendar integration

Priority Levels (High, Medium, Low)

Categories & Tags for organization

Subtasks for breaking down complex tasks

Task Notes for additional details

🎯 Productivity Features
Push Notifications for due tasks

Recurring Tasks (daily, weekly, monthly)

Task Sharing with other users

Progress Tracking with visual indicators

Search & Filter by text, date, priority, category

Dark/Light Theme support

☁️ Cloud Features
Real-time Sync across all devices

Offline Support with automatic sync when online

Cloud Backup & data recovery

Multi-device synchronization

🚀 Quick Start
Prerequisites
Flutter SDK (3.0.0 or higher)

Firebase Account

Android Studio or VS Code

Android/iOS Emulator or physical device

Installation
Clone the repository

bash
git clone https://github.com/Taiwo156/TodoApp.git
cd TodoApp
Install dependencies

bash
flutter pub get
Firebase Setup

Android:
Create a new Firebase project at Firebase Console

Add Android app to your Firebase project

Download google-services.json and place it in android/app/

Enable Authentication (Email/Password & Google) in Firebase Console

iOS (if developing for iOS):
Add iOS app to your Firebase project

Download GoogleService-Info.plist and place it in ios/Runner/

Configure iOS bundle ID in Xcode

Run the application

bash
flutter run
Firebase Configuration
Enable Authentication Methods:

Email/Password

Google Sign-In

Firestore Database Setup:

bash
# Security rules (place in firestore.rules)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/todos/{todoId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /users/{userId}/categories/{categoryId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
Firebase Storage (for task attachments):

bash
# Storage rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/attachments/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
📁 Project Structure
text
lib/
├── main.dart                      # Application entry point
├── models/                        # Data models
│   ├── todo_model.dart
│   ├── user_model.dart
│   └── category_model.dart
├── providers/                     # State management
│   ├── auth_provider.dart
│   ├── todo_provider.dart
│   └── theme_provider.dart
├── services/                      # Firebase services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── notification_service.dart
├── screens/                       # App screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── todo_list_screen.dart
│   │   └── add_edit_todo_screen.dart
│   └── profile/
│       ├── profile_screen.dart
│       └── settings_screen.dart
├── widgets/                       # Reusable widgets
│   ├── todo_tile.dart
│   ├── priority_chip.dart
│   ├── category_chip.dart
│   └── custom_textfield.dart
├── utils/                         # Utilities & constants
│   ├── constants.dart
│   ├── helpers.dart
│   └── theme.dart
└── assets/                        # Images, icons, fonts
    ├── images/
    ├── icons/
    └── fonts/
🛠️ Technologies Used
Frontend Framework: Flutter 3.0+

Backend & Auth: Firebase Authentication

Database: Cloud Firestore

Storage: Firebase Storage (for attachments)

Notifications: Firebase Cloud Messaging

State Management: Provider/Riverpod

Local Storage: Shared Preferences/Hive

📱 Building for Production
Android
bash
flutter build apk --release
# or
flutter build appbundle --release
iOS
bash
flutter build ios --release
Web
bash
flutter build web --release
🔧 Configuration
Environment Variables
Create a lib/config/env.dart file:

dart
class Env {
  static const String appName = 'TodoApp';
  static const String supportEmail = 'support@todoapp.com';
  // Add other configuration variables
}
Firebase Configuration
Update android/app/build.gradle:

gradle
android {
    // ...
    defaultConfig {
        applicationId "com.yourcompany.todoapp"
        minSdkVersion 21
        targetSdkVersion 33
        // ...
    }
}
📊 Firebase Security Rules
Firestore Rules
javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /todos/{todoId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /categories/{categoryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
🎨 Customization
Themes
The app supports light and dark themes. Customize in lib/utils/theme.dart:

dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    // Add your customizations
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    // Add your customizations
  );
}
Adding New Features
Create model in lib/models/

Add provider in lib/providers/ if needed

Create service in lib/services/ for Firebase operations

Build UI components in lib/widgets/

Add screens in lib/screens/

🤝 Contributing
We welcome contributions! Please see our Contributing Guidelines for details.

Fork the repository

Create a feature branch (git checkout -b feature/AmazingFeature)

Commit your changes (git commit -m 'Add some AmazingFeature')

Push to the branch (git push origin feature/AmazingFeature)

Open a Pull Request

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

🐛 Troubleshooting
Common Issues
Firebase not connecting

Check your google-services.json placement

Verify package name matches in Firebase and Android manifest

Authentication issues

Ensure Authentication methods are enabled in Firebase Console

Check SHA-1 fingerprint for Android app

Build errors

bash
flutter clean
flutter pub get
flutter run
Getting Help
📧 Email: oluboyedetaiwo156@gmail.com

🐛 Issues: GitHub Issues

💬 Discussions: GitHub Discussions
