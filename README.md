# 🎮 GameBoy Tinder - Retro Dating App

<div align="center">

![GameBoy Style Dating App](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Node.js Backend](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Supabase Database](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)

*A nostalgic dating app that brings the classic GameBoy experience to modern mobile dating*

</div>

## 📖 Overview

GameBoy Tinder is a unique mobile dating application that recreates the iconic GameBoy handheld gaming experience. Users navigate through profiles using authentic GameBoy controls (D-pad, A/B buttons) while enjoying retro aesthetics, grainy textures, and authentic 8-bit sound effects.

### ✨ Key Features

- 🎮 **Authentic GameBoy Interface** - Complete with D-pad navigation, A/B buttons, and classic design
- 🔊 **Retro Sound Effects** - Authentic button clicks and navigation sounds
- 🖥️ **Grainy Texture System** - Realistic CRT-style visual effects for true retro feel
- 👤 **Profile Matching** - Swipe through profiles using GameBoy controls
- 🔐 **Secure Authentication** - JWT-based login/registration system
- 📱 **Cross-Platform** - Built with Flutter for iOS, Android, and Web
- 🗄️ **Robust Backend** - Node.js + Supabase for scalable data management

## 🏗️ Architecture

### Frontend (Flutter)
```
lib/
├── main.dart                 # App entry point with sound initialization
├── screens/                  # Main application screens
│   ├── login_screen.dart     # GameBoy-themed login interface
│   ├── register_screen.dart  # Registration with retro styling
│   └── homepage.dart         # Profile browsing interface
├── widgets/                  # Reusable GameBoy components
│   ├── gameboy_screen.dart   # Classic GameBoy screen simulation
│   ├── gameboy_dpad.dart     # D-pad navigation control
│   ├── gameboy_button.dart   # A/B button components
│   ├── grainy_texture.dart   # Retro texture system
│   └── gameboy_*.dart        # Additional UI components
└── services/                 # Business logic and integrations
    ├── api_service.dart      # Backend API communication
    └── gameboy_sound.dart    # Retro sound system
```

### Backend (Node.js + Supabase)
```
server/
├── server.js                 # Express server configuration
├── config/
│   └── supabase.js          # Database connection setup
├── routes/                   # API endpoint definitions
│   ├── auth.js              # Authentication endpoints
│   ├── users.js             # User management
│   ├── profiles.js          # Profile operations
│   └── matches.js           # Matching logic
├── middleware/               # Custom middleware
│   └── auth.js              # JWT authentication
└── database_setup.sql       # Database schema
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (≥3.8.1)
- **Node.js** (≥18.0.0)
- **Supabase Account** (for database)
- **iOS Simulator** or **Android Emulator**

### 🔧 Installation

#### 1. Clone the Repository
```bash
git clone https://github.com/your-username/gameboy-dating-app.git
cd gameboy-dating-app
```

#### 2. Backend Setup
```bash
cd server
npm install
```

Create `.env` file in server directory:
```env
PORT=3000
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
JWT_SECRET=your_jwt_secret_key
```

Set up database:
```bash
# Run the database setup script
node setup-db.js
```

Start the backend server:
```bash
npm run dev
```

#### 3. Frontend Setup
```bash
cd ..  # Back to root directory
flutter pub get
```

Update API endpoint in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-server-url:3000/api';
```

Run the Flutter app:
```bash
flutter run
```

## 🎮 Usage Guide

### Navigation Controls

| Control | Action |
|---------|--------|
| **D-Pad ↑↓** | Navigate menu items |
| **D-Pad ←→** | Change profile images |
| **A Button** | Select/Confirm action |
| **B Button** | Back/Cancel |
| **SELECT** | Show controls menu |
| **START** | Logout/Settings |

### Features Walkthrough

#### 🔐 Authentication
- **Login/Register** with GameBoy-themed interface
- **D-pad navigation** through form fields
- **Sound feedback** for success/error states
- **Secure JWT authentication**

#### 👤 Profile Browsing
- **Navigate profiles** using D-pad left/right
- **View multiple images** per profile
- **Like/Pass decisions** with A/B buttons
- **Profile information toggle** with CENTER button

#### 🔊 Sound System
- **Button clicks** - Authentic GameBoy button sounds
- **Navigation** - Lighter D-pad movement sounds
- **Success/Error** - Contextual audio feedback
- **Sound toggle** - Enable/disable via controls menu


## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Nintendo GameBoy** - Inspiration for the iconic design
- **Flutter Team** - Amazing cross-platform framework
- **Supabase** - Excellent backend-as-a-service platform
- **Community** - Open source packages and resources

## 📞 Support

For support, email your-email@example.com or create an issue in the GitHub repository.

---

<div align="center">

**Built with ❤️ and nostalgia for the golden age of handheld gaming**

[Report Bug](https://github.com/your-username/gameboy-dating-app/issues) • [Request Feature](https://github.com/your-username/gameboy-dating-app/issues) • [Documentation](https://github.com/your-username/gameboy-dating-app/wiki)

</div>
