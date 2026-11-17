# ⚡ FlashStudy — Clean Architecture Flashcard Quiz App

A modern, offline-first study and flashcard quiz application built with **Flutter 3** following **Clean Architecture (MVVM)** principles, featuring interactive 3D card flips, deck customization, and a sleek **Linear/Notion-inspired** user experience styled in **Sunset Coral & Warm Amber**.

---

## 📱 Features

- 🃏 **3D Flip Cards**: Smooth $180^\circ$ perspective flip animation revealing question front and answer back with dedicated "Show Answer" and "Hide Answer" controls.
- 🔄 **Deck Navigation**: Navigate through cards seamlessly with Next and Previous buttons, plus horizontal touch swipe gestures.
- ✏️ **Full Deck Customization (CRUD)**:
  - Add new flashcards with customizable categories and validation.
  - In-place editing of existing flashcards.
  - Safe deletion with confirmation dialogs.
- 🔍 **Keyword Search & Filter**: Easily filter cards across questions, answers, and topic tags.
- 🔀 **Shuffle & Progress Tracking**: Randomize card order on the fly and track study completion via a dynamic gradient progress bar.
- 💾 **Persistent Offline Storage**: Retains all customized flashcards across app restarts via `SharedPreferences`.
- 🌓 **Adaptive Light & Dark Mode**: Handcrafted for high-contrast, distraction-free study sessions.

---

## 🏛️ Clean Architecture & MVVM Structure

The project strictly follows Uncle Bob's Clean Architecture standards, dividing concerns into distinct layers:

```text
lib/
├── core/
│   ├── di/
│   │   └── service_locator.dart               # Dependency Injection Container (Service Locator)
│   ├── errors/
│   │   └── failures.dart                      # Core Failures & Exceptions
│   └── theme/
│       └── app_theme.dart                     # Sunset Coral & Warm Amber theme configurations
│
├── domain/                                    # Enterprise & Business Logic (Pure Dart)
│   ├── entities/
│   │   └── flashcard_entity.dart              # Pure immutable Flashcard entity
│   ├── repositories/
│   │   └── flashcard_repository.dart          # Abstract Repository contract
│   └── usecases/                              # Single-responsibility interactors
│       ├── get_flashcards_usecase.dart        # Retrieve cards
│       ├── add_flashcard_usecase.dart         # Add card to deck
│       ├── update_flashcard_usecase.dart      # Modify card content
│       └── delete_flashcard_usecase.dart      # Delete card by ID
│
├── data/                                      # Data Access Layer
│   ├── datasources/
│   │   └── flashcard_local_data_source.dart   # SharedPreferences persistence + default seed cards
│   ├── models/
│   │   └── flashcard_model.dart               # Data model extending Entity with JSON serialization
│   └── repositories/
│       └── flashcard_repository_impl.dart     # Repository implementation mapping models to domain
│
├── presentation/                              # UI & State Management (MVVM)
│   ├── view_models/
│   │   └── flashcard_view_model.dart          # ChangeNotifier managing state & handling user actions
│   ├── views/
│   │   ├── study_view.dart                    # Main Quiz/Study screen (Next/Prev, 3D flip, gestures)
│   │   └── manage_cards_view.dart             # Deck management screen (search, list, CRUD operations)
│   └── widgets/
│       ├── flip_card_widget.dart              # 3D animated flip card (Question front / Answer back)
│       └── flashcard_dialog.dart              # Validated Add / Edit modal dialog
│
└── main.dart                                  # App entry point with async DI bootstrapping
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.47.x or later)
- Dart SDK (3.13.x or later)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/shehabshawky/flashcard_app.git
   cd flashcard_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🧪 Testing

The application includes automated unit and widget test suites covering ViewModel business logic and user interactions:

```bash
# Run all tests
flutter test

# Run static analysis
flutter analyze
```

---

## 🎨 Color Palette & Design System

- **Primary Accent**: Sunset Coral (`#FF5A5F`)
- **Secondary Accent**: Warm Amber (`#F59E0B`)
- **Dark Surface**: Obsidian Slate (`#0E1117` / `#181C26`)
- **Light Surface**: Warm Off-White (`#FAF9F7` / `#FFFFFF`)
- **Typography**: Refined, tight letter-spacing inspired by Notion & Linear.

---

## 📄 License

This project is open-source and available under the MIT License.
