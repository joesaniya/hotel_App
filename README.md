# MyTravaly

A modern, cross-platform **Hotel Booking Application** built using **Flutter** and **Provider** for state management.  
This project demonstrates clean architecture, structured state management, and elegant UI design.

## Overview

The Hotel App enables users to **sign in with Google**, **browse hotel listings**, and **search for hotels** using a powerful, paginated search API.  
It’s designed to showcase best practices in Flutter development, including clean code organization and separation of concerns.

## Features

### **Page 1 - Google Sign In / Sign Up**

- Implemented using `google_sign_in` package.
- Frontend-only (no backend connection required).
- Clean UI showcasing Google authentication integration flow.

### **Page 2 - Home Page (Hotel List)**

- Displays a curated list of **sample hotels**.
- Built-in **search bar** to filter by:
  - Hotel name
  - City
  - State
  - Country
- Managed using **Provider** for reactive updates.

### **Page 3 - Search Results**

- Fetches hotel data using **Dio-based API calls**.
- Implements **pagination** for efficient infinite scrolling.
- Displays structured, responsive hotel cards.

---

## Project Architecture

### Directory Structure

lib/
├── business_logic/
│ ├── app_settings_provider.dart
│ ├── auth_provider.dart
│ ├── home_provider.dart
│ └── provider_common.dart
│
├── data-provider/
│ ├── dio-client.dart
│ └── models/
│
├── screens/
│ ├── bottom_sheet_widget/
│ ├── widgets/
│ ├── app_setting_screen.dart
│ ├── home_detail_screen.dart
│ ├── home_screen.dart
│ ├── hotel_result_screen.dart
│ ├── sign_in_screen.dart
│ └── splash_screen.dart
│
├── services/
│ ├── api_service.dart
│ ├── app_settings_service.dart
│ ├── device_registration_service.dart
│ ├── google_sign_in_service.dart
│ ├── hotel_search_service.dart
│ ├── local_storage_service.dart
│ └── firebase_options.dart
│
└── main.dart

yaml
Copy code

### Layered Approach

| Layer              | Description                                                         |
| ------------------ | ------------------------------------------------------------------- |
| **business_logic** | Application state management using Provider.                        |
| **data-provider**  | Networking (Dio client) and model serialization.                    |
| **screens**        | UI components and navigation screens.                               |
| **services**       | Core business services like authentication, API calls, and storage. |

---

## Setup & Installation

### 1️ Clone the Repository

```bash
git clone https://github.com/joesaniya/hotel_App.git
cd hotel_app
Install Dependencies

flutter pub get
flutter run

Firebase Setup
If using Google Sign-In with Firebase:

Add your google-services.json (Android) or GoogleService-Info.plist (iOS).

Verify configuration in firebase_options.dart.

API Integration
The app uses a hotel search API to fetch and display hotels dynamically.

Handled in: hotel_search_service.dart

Handles pagination.

Maps JSON response to model classes.

Manages loading and error states using Provider.

Dependencies
yaml
Copy code
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5+1
  firebase_core: ^3.7.0
  firebase_auth: ^5.3.2
  google_sign_in: ^6.2.1
  dio:
  pretty_dio_logger: ^1.4.0
  google_fonts: ^6.3.2
  shared_preferences: ^2.5.3
  flutter_svg: ^2.2.1
  device_info_plus: ^12.2.0
  intl: ^0.20.2
  url_launcher: ^6.3.2

UI / UX Highlights
Modern, clean Material 3 design.

Typography via Google Fonts.

Fully responsive layout

Reusable components and bottom sheets.

Smooth animations and consistent padding/margins.

Author
Esther Jenslin Johnson
Flutter Developer
```
