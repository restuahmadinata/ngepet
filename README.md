# Ngepet - Pet Adoption Platform

Ngepet is a comprehensive mobile application built with Flutter that connects animal shelters with potential adopters, making pet adoption more accessible and streamlined.

## Overview

Ngepet serves as a bridge between animal shelters and people looking to adopt pets. The platform provides a complete solution for managing pet listings, adoption requests, shelter operations, and administrative oversight, all while maintaining real-time communication through an integrated chat system.

## Key Features

### For Users (Adopters)
- **Pet Discovery**: Browse available pets with detailed profiles, photos, and health information
- **Advanced Filtering**: Search pets by species, breed, age, gender, size, and location
- **Adoption Requests**: Submit and track adoption applications
- **Real-time Chat**: Communicate directly with shelters about pets
- **Profile Management**: Manage personal information and adoption history
- **Location-based Search**: Find nearby shelters using integrated mapping

### For Shelters
- **Pet Management**: Create and manage comprehensive pet listings
- **Adoption Processing**: Review and process adoption requests
- **Communication Tools**: Chat with potential adopters
- **Dashboard Analytics**: Track pets, adoptions, and shelter performance
- **Profile & Gallery**: Showcase shelter facilities and success stories

### For Administrators
- **User Management**: Monitor and manage user accounts and permissions
- **Shelter Verification**: Approve and manage shelter registrations
- **System Oversight**: Monitor platform usage and generate reports
- **Content Moderation**: Review and manage listings and user content

### Core Capabilities
- **Push Notifications**: Local notification system for chat messages and updates (no external service required)
- **Image Management**: Upload and compress images for optimal performance
- **Offline Support**: Cached data for improved user experience
- **Real-time Updates**: Instant synchronization across all users
- **Responsive Design**: Optimized for various screen sizes and orientations

## Technology Stack

### Framework & Language
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language (SDK ^3.9.2)

### Backend Services
- **Firebase Core**: Backend infrastructure
- **Cloud Firestore**: Real-time NoSQL database
- **Firebase Authentication**: User authentication and authorization

### State Management & Navigation
- **GetX**: State management, dependency injection, and routing

### UI Components
- **Google Fonts**: Custom typography (Poppins)
- **Flutter SVG**: Vector graphics rendering
- **Lottie**: Animation support
- **FL Chart**: Data visualization
- **Photo View**: Image viewing and zooming

### Media & Storage
- **Cached Network Image**: Image caching for performance
- **Image Picker**: Gallery and camera integration
- **Flutter Image Compress**: Image optimization

### Location Services
- **Flutter Map**: OpenStreetMap integration (no API key required)
- **Latlong2**: Coordinate handling
- **Geolocator**: Device location access

### Utilities
- **Connectivity Plus**: Network status monitoring
- **HTTP**: RESTful API communication
- **Flutter Local Notifications**: Push notification system

## Project Structure

```
lib/
├── app/
│   ├── common/          # Shared components and controllers
│   ├── config/          # App configuration
│   ├── features/        # Feature modules
│   │   ├── admin/       # Admin functionality
│   │   ├── auth/        # Authentication
│   │   ├── shelter/     # Shelter management
│   │   └── user/        # User features
│   ├── models/          # Data models
│   ├── routes/          # Navigation routes
│   ├── services/        # Business logic services
│   ├── theme/           # App theming
│   ├── utils/           # Utility functions
│   └── widgets/         # Reusable widgets
├── firebase_options.dart
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (^3.9.2 or later)
- Dart SDK (^3.9.2 or later)
- Android Studio / Xcode (for mobile development)
- Firebase account and project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ngepet
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android/iOS apps to your Firebase project
   - Download and place `google-services.json` in `android/app/`
   - Download and place `GoogleService-Info.plist` in `ios/Runner/`
   - Run FlutterFire CLI to generate Firebase options:
     ```bash
     flutterfire configure
     ```

4. **Configure Firestore**
   - Set up Firestore security rules using `firestore.rules`
   - Deploy indexes from `firestore.indexes.json`
   - Refer to `FIREBASE_STRUCTURE.md` for database schema

5. **Run the application**
   ```bash
   flutter run
   ```

## Configuration Files

- `analysis_options.yaml` - Dart analyzer configuration
- `firebase.json` - Firebase project configuration
- `firestore.rules` - Firestore security rules
- `firestore.indexes.json` - Database indexes
- `storage.rules` - Firebase Storage security rules

## Documentation

Additional documentation is available in the following files:

- `FIREBASE_STRUCTURE.md` - Complete Firestore database schema
- `IMPLEMENTATION_SUMMARY.md` - Implementation details and architecture
- `CHAT_NOTIFICATIONS.md` - Notification system documentation
- `TESTING_NOTIFICATIONS.md` - Notification testing guide
- `ENUM_IMPLEMENTATION.md` - Enum usage and type safety
- `PERFORMANCE_OPTIMIZATIONS.md` - Performance improvement strategies
- `INTEGRATION_TESTING.md` - Testing procedures
- `SETUP_TEST_ACCOUNT.md` - Test account setup guide

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/app_test.dart
```

For detailed testing procedures, refer to `INTEGRATION_TESTING.md`.

## Build & Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Architecture Highlights

### Clean Architecture
The project follows clean architecture principles with clear separation between:
- **Presentation Layer**: UI widgets and controllers
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Models and service integration

### State Management
GetX is used throughout the application for:
- Reactive state management
- Dependency injection
- Route management
- Internationalization support

### Real-time Data
Firestore streams provide real-time updates for:
- Pet listings
- Chat messages
- Adoption requests
- User status changes

## Performance Considerations

- Image compression reduces bandwidth and storage costs
- Cached network images improve load times
- Lazy loading for large datasets
- Optimized Firestore queries with proper indexing
- Local notifications eliminate third-party service dependencies

## License

This project is licensed under the terms specified in the `LICENSE` file.

## Support

For issues, questions, or contributions, please refer to the project documentation or create an issue in the repository.

## Version

Current Version: 1.0.0+1
