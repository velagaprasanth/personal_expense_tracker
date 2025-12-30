# Personal Expense Tracker

A Supabase-backed Flutter application that lets authenticated users create, view, update, and delete their personal expenses (and optional incomes) while keeping Material 3 styling, GoRouter navigation, and Riverpod state management.

## Table of Contents
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Running & Testing](#running--testing)
- [Code Generation](#code-generation)
- [Demo Video](#demo-video)
- [Project Structure](#project-structure)

## Features
- Email/password authentication (Supabase Auth) with session persistence and logout.
- Guarded routing via GoRouter; unauthenticated users only see onboarding/login/register.
- Expense CRUD with validation for title, amount, category, and date.
- Swipe-to-edit/delete gestures on both the home feed and wallet history.
- Summary cards for balance, total income, and total expenses.
- Fixed expense categories (Food, Travel, Shopping, Bills, Others) per assessment and curated income categories.
- Material 3 themed UI with responsive add expense/income sheets.

## Architecture
- **Presentation**: Flutter screens/widgets under `lib/screens` and `lib/widgets`.
- **State Management**: Riverpod (code-generated providers) under `lib/providers`.
- **Routing**: GoRouter shell route powering the bottom navigation bar plus guarded auth redirects.
- **Data Layer**: `TransactionService` encapsulates Supabase calls, using `Transaction` model serialized via `json_serializable`.

## Tech Stack
| Layer        | Choice |
|--------------|--------|
| Framework    | Flutter 3.8 (Material 3) |
| Routing      | GoRouter 14 |
| State        | flutter_riverpod + riverpod_annotation |
| Backend      | Supabase (PostgreSQL + Auth) |
| Charts       | fl_chart |
| Tooling      | json_serializable, build_runner |

## Getting Started
1. **Clone the repo**
	```bash
	git clone https://github.com/velagaprasanth/personal_expense_tracker.git
	cd personal_expense_tracker
	```
2. **Install dependencies**
	```bash
	flutter pub get
	```
3. **Configure Supabase** – update `lib/config/supabase_config.dart` with your Supabase URL and anon key (see [Environment Variables](#environment-variables)).
4. **Connect a device/emulator** and run:
	```bash
	flutter run
	```

## Environment Variables
Supabase credentials are read from `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const supabaseUrl = 'https://your-project.supabase.co';
  static const supabaseAnonKey = 'public-anon-key';
}
```

Update both constants with your project values before running the app.

## Running & Testing
- **Launch the app**: `flutter run`
- **Analyzer & formatting**: `dart analyze` and `dart format lib test`
- **Widget tests** (placeholder sample): `flutter test`

## Code Generation
This project relies on generated files for Riverpod providers and JSON serializers. Regenerate whenever you update models/providers:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Demo Video
- _Requirement_: record a 3–5 minute walkthrough demonstrating authentication, the expense CRUD flow, and a quick code overview.
- _Action_: capture the video (screen recording + narration), upload it (e.g., unlisted YouTube, Google Drive), and paste the public link below.
- **Placeholder**: Demo link pending – update this section once the video is hosted.

## Project Structure
```
lib/
 ├─ config/              # Supabase credentials
 ├─ models/              # Data classes (json_serializable)
 ├─ providers/           # Riverpod providers (code-generated)
 ├─ routes/              # GoRouter configuration + auth guards
 ├─ screens/             # Feature screens (auth, home, add expense, etc.)
 ├─ services/            # Supabase data access layer
 └─ widgets/             # Shared UI components (bottom nav, etc.)
```

Feel free to open an issue or PR if you spot bugs or want to contribute improvements.
