# University Housing Management System

A comprehensive mobile application for managing university housing operations, built with Flutter and Supabase.

## Overview

The University Housing Management System streamlines housing operations for students, administrators, supervisors, and labor staff. The app provides an intuitive UI, secure authentication, real-time updates, and automation for key processes.

## Features

### User Authentication
- Role-based authentication system (Students, Administrators, Supervisors, Labor Staff)
- Secure login and registration

### Student Features
- Housing registration and status tracking
- Online payment processing
- QR code-based attendance system
- Vacation request submission
- Eviction (moving out) request process

### Administrator Features
- Dashboard with housing statistics
- Registration approval system
- Payment records management
- Student housing management
- Housing unit management

### Supervisor Features
- Attendance tracking via QR scanning
- Vacation request approvals
- Eviction process management
- Cleaning task assignment and tracking

### Labor Staff Features
- Cleaning task management
- Task completion tracking
- Work history

## Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Dart SDK
- Android Studio / VS Code
- Supabase account

### Installation

1. Clone the repository:
```
git clone https://github.com/yourusername/universityhousing.git
```

2. Navigate to the project directory:
```
cd universityhousing
```

3. Install dependencies:
```
flutter pub get
```

4. Set up Supabase:
   - Create a new Supabase project
   - Update the Supabase URL and anon key in `lib/main.dart`

5. Run the app:
```
flutter run
```

## Project Structure

```
lib/
  ├── constants/       # App constants like colors
  ├── models/          # Data models
  ├── providers/       # State management
  ├── screens/         # UI screens
  ├── services/        # API services
  ├── utils/           # Helper functions
  └── widgets/         # Reusable UI components
```

## Technical Implementation

- **Backend**: Supabase for database, authentication, and storage
- **State Management**: Provider pattern
- **Authentication**: JWT-based authentication with Supabase
- **QR Code System**: For student attendance tracking
- **Payment Processing**: Secure payment integration
- **UI/UX**: Material Design with custom theme

## Future Enhancements

- Push notifications for updates
- Meal plan integration
- Maintenance request system
- Chat support for students
- Analytics dashboard for administrators

## License

This project is licensed under the MIT License - see the LICENSE file for details.
