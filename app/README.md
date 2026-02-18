# Resp-AI Flutter App (The Instrument) 📱

This is the high-fidelity data capture and visualization frontend for the **Resp-AI** system.

## 🚀 Key Features

- **Real-time Audio Streaming:** Raw PCM 16-bit audio is streamed directly to the AI backend via WebSockets.
- **Modern UI/UX:** Built with Flutter, featuring smooth animations and a responsive design.
- **State Management:** Uses **Riverpod** for robust and predictable state handling.
- **Cross-Platform:** Supports Android, iOS, Windows, macOS, and Linux.

## 🛠️ Getting Started

1.  **Dependencies:** Run `flutter pub get` to install all necessary packages.
2.  **Configuration:** The app connects to the backend at `http://127.0.0.1:8000` by default.
3.  **Run:** Execute `flutter run` and select your target device.

## 📁 Project Structure

- `lib/services/`: Core logic for Audio (`AudioService`) and API (`ApiService`) communication.
- `lib/providers/`: Riverpod state management.
- `lib/screens/`: UI implementation for Home and Results.
- `lib/models/`: Type-safe data models for AI results.

## 📜 Testing

Refer to `TESTING_GUIDE.md` for detailed instructions on running and verifying the application.
